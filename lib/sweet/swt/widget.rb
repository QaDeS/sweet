require 'forwardable' # TODO remove?

class Java::OrgEclipseSwtWidgets::Widget
  include Sweet::Component

  def sweet_block_handler(handler, &block)
    return false unless handler.is_a? Numeric
    addListener handler, &block
    true
  end

  # TODO unify this layout mess somehow
  # TODO hierarchical hash for nicer client code
  def grid_data=(*options)
    opts = {}
    options.each do |(k, v)|
      opts[k] = v
    end
    ax, ay = opts[:align]
    gx, gy = opts[:grab]
    sx, sy = opts[:span]
    args = [ax || swt::BEGINNING, ay || swt::CENTER,
      gx || false, gy || false, sx || 1, sy || 1]
    puts args.inspect
    args.map!{|v| v.is_a?(Symbol) ? v.swt_const : v}
    Sweet.debug args.inspect
    l = layouts::GridData.new(*args)
    self.layout_data = l
  end
  def row_data=(x, y = nil)
    self.layout_data = layouts::RowData.new(x || swt::DEFAULT, y || swt::DEFAULT)
  end

  def hide
    self.visible = false
  end
  def show
    self.visible = true
  end

  def width
    size.x
  end
  def width=(value)
    Sweet.debug "width=(#{value.inspect})"
    setSize(value, height)
  end

  def height
    size.y
  end
  def height=(value)
    self.size = nil, value
  end

  def size=(*s)
    Sweet.debug "size=(#{s.inspect})"
    nw, nh = s.flatten
    nw ||= width
    nh ||= height
    Sweet.debug "setSize(#{nw.inspect}, #{nh.inspect})"
    setSize(nw, nh)
  end

  def popup(&block)
    self.menu = make_menu(:popup, &block)
  end

  private
  def make_menu(type, &block)
    Sweet.create_widget(sweet_containers.last, type, &block)
  end

  # TODO replace via import?
  def swt
    org.eclipse.swt.SWT
  end
  def widgets
    org.eclipse.swt.widgets
  end
  def layouts
    org.eclipse.swt.layout
  end
  def custom
    org.eclipse.swt.custom
  end

end

