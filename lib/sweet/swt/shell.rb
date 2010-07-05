# TODO pack into WIDGETS
class Java::OrgEclipseSwtWidgets::Shell
  attr_reader :display
  alias_property :title => :text

  def sweeten(display, name, opts = {}, &block)
    @display = display

    self.text = opts.delete(:title) || name
    w, h = opts.delete(:width), opts.delete(:height)

    super(self, opts, &block)

    pack
    size = (w || width), (h || height)
  end

  def menubar(&block)
    self.menu_bar = make_menu(:menubar, &block)
  end

end
