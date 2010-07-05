$: << File.join(File.dirname(__FILE__), '../../lib')
require 'sweet/wxruby'
Sweet.set_debug

Sweet.app 'My first Application', :layout => :flow do
  label 'Your name:'
  @name = edit_line :columns => 10

  button 'Push me' do
    puts "Hello, #{@name.text}!"
  end
end
