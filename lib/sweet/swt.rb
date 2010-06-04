require 'sweet/swt/downloader'

begin
  load Sweet::SWT_JAR
rescue LoadError => e
  STDERR.puts "No swt.jar found. Run:"
  STDERR.puts "  sweet install [toolkit]"
  exit
end

require 'sweet/base'

require 'java'
%w{widget composite shell dialog}.each{|file| require "sweet/swt/#{file}"}

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

  default = {:init_args => :text, :block_handler => SWT::Selection}
  button_default = default.merge(:class => Button)
  WIDGET_DEFAULTS = {
    # Text components
    :label => {:style => SWT::WRAP, :init_args => :text},
    :edit_line => {:class => Text, :style => SWT::SINGLE | SWT::BORDER, :init_args => :text, :block_handler => :on_widget_default_selected},
    :edit_area => {:class => Text, :style => SWT::MULTI | SWT::BORDER, :init_args => :text, :block_handler => :on_widget_default_selected},

    # Buttons
    :button => default.merge(:style => SWT::PUSH),
    :toggle_button => button_default.merge(:style => SWT::TOGGLE),
    :radio_button => button_default.merge(:style => SWT::RADIO),
    :check_button => button_default.merge(:style => SWT::CHECK),
    :arrow_button => button_default.merge(:style => SWT::ARROW),

    # Menus
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
    
    # Toolbars
    :tool_item => default.merge(:style => SWT::PUSH),
    # TODO make CoolBar work
    #    :cool_item => {:init_args => :control, :block_handler => proc{ |c, opts, proc|
    #        c.control = proc.call
    #      }},

    # Tabs
    :tab_folder => {:class => CTabFolder, :style => SWT::BORDER},
    :tab_item => {:class => CTabItem, :style => SWT::CLOSE, :init_args => [:text, :control], :block_handler => proc{|c, opts, proc|
        c.control = proc.call
      }},

    # Other components
    :tree => {:style => SWT::VIRTUAL, :block_handler => SWT::Selection},
    :progress => {:class => ProgressBar, :style => SWT::SMOOTH},
    :group => {:init_args => :text},

    # Dialogs
    :color_dialog => {:style => SWT::APPLICATION_MODAL, :init_args => :text}
  }

  def self.create_app(name, opts, &block)
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
  
  def self.create_widget_class(cls, init)
    # build widget with default accessors
    cls.is_a?(Class) ? cls : const_get(cls)
  end

  def self.initialize_widget(parent, cls, opts, init)
    style = to_style(opts.delete(:style) || init[:style] || SWT::NONE)
    style |= to_style(opts.delete(:add_style) || 0)

    Sweet.debug "Creating #{cls.java_class.simple_name}(#{parent}, #{style})"
    cls.new(parent, style)
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
        cls.send(:alias_method, s, j) unless cls.respond_to?(s)
      else
        evts.each do |evt|
          s = evt.name.underscore
          if s.split(/_/).size == 1 && n != default_listener
            s = n + "_" + s
          end
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

  private
  def self.to_style(style)
    Array(style).inject(0) do |result, value|
      value = value.swt_const if value.is_a? Symbol
      result | value
    end
  end

end
