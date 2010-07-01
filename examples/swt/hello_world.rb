$: << File.join(File.dirname(__FILE__), '../../lib')
require 'sweet/swt'

Sweet.app 'My first Application', :layout => :fill do
  label 'Your name:'
  @name = edit_line

  button 'Push me' do
    puts "Hello, #{@name.text}!"
  end
end