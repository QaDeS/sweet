require 'swt/swt-debug.jar'
require 'java'
require 'sweet/hacks'
require 'sweet/widget'
require 'sweet/composite'
require 'sweet/shell'

# TODO create gemspec
# TODO github repos
# TODO evaluate integration of jface
module Sweet

  import 'org.eclipse.swt'
  import 'org.eclipse.swt.widgets'
  import 'org.eclipse.swt.custom'
  import 'org.eclipse.swt.browser'

  # TODO integrate all standard widgets
  WIDGET_HACKS = {
    ProgressBar => {:custom_code => proc {
        def fraction=(value)
          setSelection value.to_f * maximum
        end
        def fraction
          selection / maximum
        end
      }},
    Text => {:custom_code => proc{
        def password=(value)
          self.echo_char = ?* if value
        end
        def password
          ! echo_char.nil?
        end
      }},
    CTabFolder => {:default_listener => 'CTabFolder2'}
  }

  WIDGET_OPTIONS = {
    :label => {:style => SWT::WRAP, :init_args => :text},
    # a lot of containers, if not all, have a 'text' property, which would
    # shadow this awesome control. So we call it edit_line like in Shoes.
    # TODO :init_opts should create getters. Might be unified with :custom_code.
    :edit_line => {:class => Text, :style => SWT::SINGLE | SWT::BORDER, :init_args => :text, :block_handler => :on_widget_default_selected},
    :edit_area => {:class => Text, :style => SWT::MULTI | SWT::BORDER, :init_args => :text, :block_handler => :on_widget_default_selected},
    :button => {:style => SWT::PUSH, :init_args => :text, :block_handler => SWT::Selection},
    :tool_item => {:style => SWT::PUSH, :init_args => :text, :block_handler => SWT::Selection},
    :tree => {:style => SWT::VIRTUAL, :block_handler => SWT::Selection},
    :progress => {:class => ProgressBar, :style => SWT::SMOOTH},
    # TODO fake Menu container behaviour
    :menubar => {:class => Menu, :style => SWT::BAR},
    :popup => {:class => Menu, :style => SWT::POP_UP},
    :item => {:class => MenuItem, :style => SWT::PUSH, :init_args => :text, :block_handler => :on_widget_selected},
    :separator => {:class => MenuItem, :style => SWT::SEPARATOR},
    :submenu => {:class => MenuItem, :style => SWT::CASCADE, :init_args => :text, :block_handler => proc{|c, opts, block|
        sub = Menu.new(c.app, SWT::DROP_DOWN)
        sub.sweeten(c.app, opts, &block)
        c.menu = sub
      }
    },
    :tab_folder => {:class => CTabFolder, :style => SWT::BORDER},
    :tab_item => {:class => CTabItem, :style => SWT::CLOSE, :init_args => :text}
  }.unify

  WIDGETS = {}

  def self.app(*args, &block)
    # prepare the arguments
    count = args.length
    name = args.first.is_a?(String) ? args.shift : 'SWEET Application'
    raise ArgumentError.new(count, 2) if args.size > 1
    opts = args.first || {}

    # build the UI
    Display.setAppName(name)
    display = Display.new

    # TODO allow multiple shells
    shell = Shell.new(display)
    shell.sweeten(display, name, opts, &block)
    shell.open

    # dispatch loop
    while (!shell.isDisposed) do
      display.sleep unless display.readAndDispatch
    end

    display.dispose
  end

  def self.create_widget(parent, name, *args, &block)
    init = WIDGET_OPTIONS[name] || {}

    unless cls = WIDGETS[name]
      #      puts "Loading widget #{name}"
      #      filename = File.join('sweet/widget', name.to_s)
      #      begin
      #        require filename
      #      rescue LoadError
      cls = create_widget_class(name, init)
      #      end
    end

    opts = args.last.is_a?(Hash) ? args.pop : {}

    style = opts.delete(:style) || init[:style] || SWT::NONE
    style = Array(style).inject(0) do |result, value|
      value = value.swt_const if value.is_a? Symbol
      result | value
    end

    result = cls.new(parent, style)
    result.instance_variable_set(:@block_handler, init[:block_handler])

    if init_args = init[:init_args]
      opts.merge! Hash[Array(init_args).zip(args)]
    end
    result.sweeten(parent.app, opts, &block)

    result
  end

  def self.create_widget_class(name, init)
    # build widget with default accessors
    class_name = init[:class] || name
    class_name = class_name.to_s.camelize(:upper) if class_name.is_a?(Symbol)
    cls = class_name.is_a?(Class) ? class_name : const_get(class_name)

    unless WIDGETS.values.member? cls
      delegate_events(cls)
      if hacks = WIDGET_HACKS[cls]
        if custom_code = hacks[:custom_code]
          #puts "Putting custom code into #{cls}"
          cls.class_eval &custom_code
        end
      end
    end

    cls
  end

  def self.delegate_events(cls)
    hacks = WIDGET_HACKS[cls]
    default_listener = (hacks[:default_listener] || '').underscore if hacks

    methods = cls.java_class.java_instance_methods
    methods.each do |m|
      next unless m.name =~ /(add(.*)Listener)/
      j = $1
      n = $2.underscore
      p = m.parameter_types[0]
      evts = p.declared_instance_methods

      if evts.size == 1
        s = "on_#{n}"
        #puts s
        cls.send(:alias_method, s, j) unless cls.respond_to?(s)
      else
        evts.each do |evt|
          s = evt.name.underscore
          if s.split(/_/).size == 1 && n != default_listener
            s = n + "_" + s
          end
          #puts "#{cls.java_class.simple_name}.on_#{s} -> #{j}( #{p}.#{evt.name} )"
          # TODO provide addListener SWT::Xxx option
          unused_events = evts.select{ |e| e.name != evt.name }.map{ |e| "def #{e.name.underscore}(e)\nend" }.join("\n")
          cls.class_eval <<-EOF
              def on_#{s}(&block)
                l = Class.new do
                  include Java.#{p}
                  def initialize(&block)
                    @block = block
                  end
                  def #{evt.name}(e)
                    @block.call e
                  end
                  #{unused_events}
                end
                #{j} l.new(&block)
              end
          EOF
        end
      end
    end
  end

end

