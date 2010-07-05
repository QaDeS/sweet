require 'sweet/hacks'

module Sweet

  WIDGETS = {}

  def self.app(*args, &block)
    # prepare the arguments
    count = args.length
    name = args.first.is_a?(String) ? args.shift : 'SWEET Application'
    raise ArgumentError.new(count, 2) if args.size > 1
    opts = args.first || {}

    create_app(name, opts, &block)
  end

  def self.create_widget(parent, name, *args, &block)
    init = WIDGET_DEFAULTS[name] || {}

    unless cls = WIDGETS[name]
      #      puts "Loading widget #{name}"
      #      filename = File.join('sweet/widget', name.to_s)
      #      begin
      #        require filename
      #      rescue LoadError
      class_name = init[:class] || name
      class_name = class_name.to_s.camelize(:upper) if class_name.is_a?(Symbol)
      cls = create_widget_class(class_name, init)

      unless WIDGETS.values.member? cls
        delegate_events(cls)
        if hacks = WIDGET_HACKS[cls]
          if custom_code = hacks[:custom_code]
            cls.class_eval &custom_code
          end
        end
      end

      #      end
    end

    opts = args.last.is_a?(Hash) ? args.pop.dup : {}
    if init_args = init[:init_args]
      Array(init_args).zip(args).each do |(k, v)|
        opts.merge!(k => v) if v
      end
    end

    widget = initialize_widget(parent, cls, opts, init)
    widget.instance_variable_set(:@block_handler, init[:block_handler])

    widget.sweeten(parent.app, opts, &block)

    widget
  end

  @debug = ARGV.delete('--debug')
  def self.set_debug(value = true)
    @debug = value
  end
  def self.debug(text)
    # TODO add a decent logging mechanism
    puts text if @debug
  end

  module Component

    def self.included(cls)
      puts "extending #{cls}"
      cls.extend(ClassMethods)
    end

    attr_reader :app

    def sweeten(app, opts, &block)
      @app = app
      self.options = opts

      if block
        case handler = @block_handler
        when nil
          handle_container &block
        when Symbol
          handle_event handler, &block
        when Proc
          instance_eval do
            handler.call self, opts, block
          end
        else
          raise("Invalid :block_handler ",handler) unless sweet_block_handler(handler, &block)
        end
      end

      puts "Unknown properties for class #{self.class}: #{opts.keys.inspect}" unless opts.empty?
    end
    alias handle_event send

    def app(&block)
      return @app unless block
      @app.var_containers.last.instance_eval(&block)
    end

    def append(&block)
      raise "Append called without block" unless block
      handle_container &block
    end

    def meta(&block)
      @meta ||= class << self
        self
      end
      block ? @meta.class_eval(&block) : @meta
    end

    def options=(opts)
      # TODO reader method
      opts.each_pair do |k, v|
        case k
        when :hidden
          setVisible !v
        else
          name = k.to_s + "="
          next unless respond_to? name
          if v
            classname = respond_to?(:java_class) ? self.java_class.simple_name : self.class.name
            Sweet.debug "#{classname}.#{k} = #{v.inspect}"
            send name, *v
          end
          opts.delete(k)
        end
      end
    end

    def perform(&block)
      app.perform &block
    end

    def method_missing(name, *args, &block)
      app.send(name, *args, &block) rescue super
    end

    private
    def handle_container(&block)
      app.sweet_containers.push self
      app &block
    ensure
      app.sweet_containers.pop
    end

    module ClassMethods
      def alias_property(aliases = {})
        aliases.each do |from, to|
          alias_method from, to unless respond_to? to
          alias_method "#{from}=", "#{to}=" unless respond_to? "#{to}="
        end
      end
    end

  end

  module Application
    def initialize_app(root)
      sweet_containers << root
      var_containers << root
    end
    def sweet_containers
      @sweet_containers ||= []
    end
    def var_containers
      @var_containers ||= []
    end
    # TODO find suitable exception
    def perform(&block)
      raise 'perform is not implemented'
    end

    def busy(&block)
      raise 'busy is not implemented'
    end
    def method_missing(name, *args, &block)
      Sweet.create_widget(sweet_containers.last, name, *args, &block) || super
    end
  end

  class VarContainer
    include Component

    private
    def handle_container(&block)
      app.var_containers.push self
      app &block
    ensure
      app.var_containers.pop
    end
  end

end
