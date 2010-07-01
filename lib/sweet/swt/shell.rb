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

  def sweet_containers
    @sweet_containers ||= [self]
  end

  def var_containers
    @var_containers ||= [self]
  end
  
  def perform(&block)
    display.syncExec block
  end

  def busy(&block)
    Thread.new do
      perform do
        custom::BusyIndicator.showWhile(display) do
          block.call
        end
      end
    end
  end

  def menubar(&block)
    self.menu_bar = make_menu(:menubar, &block)
  end

  def method_missing(name, *args, &block)
    Sweet.create_widget(sweet_containers.last, name, *args, &block) || super
  end

end
