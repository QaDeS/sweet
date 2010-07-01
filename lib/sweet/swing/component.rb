# This is the only base class of ALL Swing components
class Java::JavaAwt::Container

  include Sweet::Component

  def layout=(value, opts = {})
    Sweet.debug "layout = #{name}(#{opts.inspect})"
    layout = "#{value.to_s.capitalize}Layout" if value.is_a?(Symbol)
    layout = instance_eval("awt.#{layout}") unless value.is_a?(Class)

    l = layout.new
    opts.each_pair do |k,v|
      l.send("#{k}=", v)
    end

    content_pane.setLayout l
    Sweet.debug content_pane.getLayout
  end

  def awt
    java.awt
  end
end