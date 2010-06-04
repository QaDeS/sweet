class Symbol
  # For configuring layouts
  def conf(opts = {})
    [self, opts]
  end
  def swt_const
    org.eclipse.swt.SWT.const_get(self.to_s.upcase)
  end
  def swt_event
    org.eclipse.swt.SWT.const_get(self.to_s.camelize(:upper))
  end
end

# TODO find those things in JRuby
class String
  def camelize(first_letter_in_uppercase = :upper)
    s = gsub(/\/(.?)/){|x| "::#{x[-1..-1].upcase unless x == '/'}"}.gsub(/(^|_)(.)/){|x| x[-1..-1].upcase}
    s[0...1] = s[0...1].downcase unless first_letter_in_uppercase == :upper
    s
  end
  def underscore
    gsub(/::/, '/').gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').tr("-", "_").downcase
  end
end

