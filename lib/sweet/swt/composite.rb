class Java::OrgEclipseSwtWidgets::Composite

  def layout=(name, opts = {})
    Sweet.debug "layout = #{name}(#{opts.inspect})"
    class_name = "#{name.to_s.capitalize}Layout"
    l = instance_eval "org.eclipse.swt.layout.#{class_name}.new"

    opts.each_pair do |k,v|
      l.send("#{k}=", v)
    end

    setLayout l
    Sweet.debug getLayout
  end
  
end
