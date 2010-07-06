require 'sweet/base'

require 'gtk2'
%w{widget application}.each { |f| require "sweet/gtk2/#{f}" }


module Sweet

  # TODO integrate all standard widgets

  WIDGET_HACKS = {
  }

  default = {:init_args => :label}
  WIDGET_DEFAULTS = {
    :edit_line => default.merge(:class => Gtk::Entry),
    :label => {:init_args => :text},
    :button => default.merge(:block_handler => :clicked),
    :flow => {:class => Gtk::HBox},
    :stack => {:class => Gtk::VBox}
  }

  def self.create_app(name, opts, &block)
    wnd = Gtk::Window.new
    class << wnd; self; end.class_eval do
      include Application
    end
    wnd.initialize_app wnd
    wnd.sweeten(wnd, {:title => name}.merge(opts), &block)
    wnd.show_all
    wnd.signal_connect :destroy do
      Gtk.main_quit
    end
    Gtk.main
  end
  
  def self.create_widget_class(class_name, init)
    class_name.is_a?(Class) ? class_name : Gtk.const_get(class_name)
  end

  def self.initialize_widget(parent, cls, opts, init)
    Sweet.debug "Creating #{cls}(#{parent})"
    widget = cls.new
    if appender = init[:appender]
      parent.send appender, widget
    else
      parent.add(widget)
    end
    widget
  end
  
  def self.delegate_events(cls)
    # nothing to do
  end

end
