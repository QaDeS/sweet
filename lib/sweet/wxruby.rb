require 'sweet/base'

require 'rubygems'
require 'wx'
%w{object application}.each{|file| require "sweet/wx/#{file}"}

module Sweet

  # TODO integrate all standard widgets
  WIDGET_HACKS = {
    Wx::TextCtrl => {:custom_code => proc{ alias text get_value; alias text= set_value} }
  }

  default = {:init_args => :text}
  WIDGET_DEFAULTS = {
    :label => default.merge(:class => Wx::StaticText),
    :edit_line => default.merge(:class => Wx::TextCtrl),
    :button => default.merge(:block_handler => :evt_button)
  }

  class App < Wx::App
    include Sweet::Application

    def initialize(name, opts, &block)
      @name, @opts, @block = name, opts, block
      super()
    end

    def on_init
      title = @opts[:title] || @name
      frame = Wx::Frame.new(nil, -1, title)
      initialize_app(frame)
      frame.sweeten(self, @opts, &@block)
      frame.show
    end
  end

  def self.create_app(name, opts, &block)
    App.new(name, opts, &block).main_loop
  end
  
  def self.create_widget_class(cls, init)
    cls.is_a?(Class) ? cls : Wx.const_get(cls)
  end

  def self.initialize_widget(parent, cls, opts, init)
    Sweet.debug "Creating #{cls}(#{parent})"
    c = cls.new(parent, -1, opts.delete(:text) || '')
    parent.get_sizer.add(c) if parent.get_sizer # TODO parameters
    c
  end
  
  def self.delegate_events(cls)
    # nothing to do
  end

end
