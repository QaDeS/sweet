class Java::JavaxSwing::JFrame
  alias_property :text => :title

  def sweeten(opts = {}, &block)
    w, h = opts.delete(:width), opts.delete(:height)

    super(self, opts, &block)

    pack
    size = (w || width), (h || height)
  end

  # TODO refactor that into sweet base class
  def sweet_containers
    @sweet_containers ||= [self]
  end

  def var_containers
    @var_containers ||= [self]
  end

  def perform(&block)
    SwingUtilities.invoke_and_wait block
  end

  def busy(&block)
    SwingUtilities.invoke_later_wait block
  end

  def method_missing(name, *args, &block)
    Sweet.create_widget(sweet_containers.last, name, *args, &block) || super
  end


end