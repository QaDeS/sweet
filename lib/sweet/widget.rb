require 'forwardable'

class Java::OrgEclipseSwtWidgets::Widget
  extend Forwardable
  attr_reader :app

  def sweeten(app, opts, &block)
    @app = app
    self.options = opts
    
    if block
      case handler = @block_handler
      when nil
        handle_container &block
      when Symbol
        send handler, &block
      when Numeric
        addListener handler, &block
      when Proc
        instance_eval do
          handler.call self, opts, block
        end
      else
        raise "Invalid :block_handler ",handler
      end
    end

    #puts "Created #{self.class}(#{style}) with parent #{parent.class}"
    puts "Unknown properties for class #{self.class}: #{opts.keys.inspect}" unless opts.empty?
  end

  def meta(&block)
    if block
      meta.class_eval &block
    else
      class << self
        self
      end
    end
  end

  def self.alias_property(aliases = {})
    aliases.each do |from, to|
      alias_method from, to unless "to"
      alias_method "#{from}=", "#{to}=" unless "#{to}="
    end
  end

  def options=(opts)
    # TODO reader method
    opts.each_pair do |k, v|
      case k
      when :hidden
        setVisible !v
      else
        name = k.to_s + "="
        if respond_to?(name)
          send name, *v if v
          opts.delete(k)
        end
      end
    end
  end


  # TODO unify this layout mess somehow
  # TODO hierarchical hash for nicer client code
  def grid_data=(*opts)
    l = layout_data
    unless l && l.is_a?(layouts::GridData)
      l = layouts::GridData.new
    end

    opts.each do |(k,v)|
      value = v.is_a?(Symbol) ? v.swt_const : v
      #puts "grid.#{k} = #{value}"
      l.send("#{k.to_s}=", value)
    end

    self.layout_data = l
  end
  def row_data=(x, y = nil)
    self.layout_data = layouts::RowData.new(x || swt::DEFAULT, y || swt::DEFAULT)
  end

  def perform(&block)
    app.perform &block
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
    self.size = value, nil
  end

  def height
    size.y
  end
  def height=(value)
    self.size = nil, value
  end

  def size=(*s)
    nw, nh = s.flatten
    nw ||= width
    nh ||= height
    setSize(nw, nh)
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

  private
  def handle_container(&block)
    app.sweet_containers.push self
    app.instance_eval &block
    app.sweet_containers.pop
  end

end

