class Java::OrgEclipseSwtWidgets::Composite

  def layout=(name, options = {})
    class_name = "#{name.to_s.capitalize}Layout"
    l = instance_eval "org.eclipse.swt.layout.#{class_name}.new"

    options.each_pair do |k,v|
      l.send("#{k}=", v)
    end

    setLayout l
  end
  
end
