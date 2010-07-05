require 'sweet/base'

require 'java'
%w{component frame}.each { |f| require "sweet/swing/#{f}" }


module Sweet

  import 'javax.swing'

  # TODO integrate all standard widgets

  WIDGET_HACKS = {
  }

  default = {:init_args => :text}
  WIDGET_DEFAULTS = {
    :edit_line => default.merge(:class => JTextField),
    :label => default,
    :button => default.merge(:block_handler => :on_action),
    :menu_bar => {:appender => :setJMenuBar}
  }

  def self.create_app(name, opts, &block)
    frame = JFrame.new(name)
    # TODO factor this out
    class << frame; self; end.class_eval do
      include Application
    end
    frame.initialize_app frame
    frame.default_close_operation = JFrame::EXIT_ON_CLOSE
    frame.sweeten(opts, &block)
    frame.visible = true
  end
  
  def self.create_widget_class(name, init)
    # build widget with default accessors
    class_name = init[:class] || name
    class_name = class_name.to_s.camelize(:upper) if class_name.is_a?(Symbol)
    cls = class_name.is_a?(Class) ? class_name : const_get('J' + class_name)

    unless WIDGETS.values.member? cls
      delegate_events(cls)
      if hacks = WIDGET_HACKS[cls]
        if custom_code = hacks[:custom_code]
          cls.class_eval &custom_code
        end
      end
    end

    cls
  end

  def self.initialize_widget(parent, cls, opts, init)
    Sweet.debug "Creating #{cls.java_class.simple_name}(#{parent})"
    widget = cls.new()
    if appender = init[:appender]
      parent.send appender, widget
    else
      if parent.respond_to?(:content_pane)
        parent.content_pane
      else
        parent
      end.add(widget)
    end
    widget
  end
  
  def self.delegate_events(cls)
    hacks = WIDGET_HACKS[cls]
    default_listener = (hacks[:default_listener] || 'action').underscore if hacks

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
