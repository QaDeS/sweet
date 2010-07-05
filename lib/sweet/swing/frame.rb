class Java::JavaxSwing::JFrame
  alias_property :text => :title

  def sweeten(opts = {}, &block)
    w, h = opts.delete(:width), opts.delete(:height)

    super(self, opts, &block)

    pack
    size = (w || width), (h || height)
  end

end