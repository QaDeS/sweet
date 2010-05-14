$: << File.join(__FILE__, '../lib')
require 'sweet'

Sweet.app 'My first Application', :layout => :fill do
  label 'Your name:'
  @name = edit_line

  button 'Push me' do
    puts "Hello, #{@name.text}!"
  end
end