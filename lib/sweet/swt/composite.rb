class Java::OrgEclipseSwtWidgets::Composite

  def layout=(name, opts = {})
    Sweet.debug "layout = #{name}(#{opts.inspect})"
    # TODO allow instantiated layouts and layout classes
    class_name = "#{name.to_s.capitalize}Layout"
    l = instance_eval "org.eclipse.swt.layout.#{class_name}.new"

    opts.each_pair do |k,v|
      l.send("#{k}=", v)
    end

    setLayout l
    Sweet.debug getLayout
  end
  
end
