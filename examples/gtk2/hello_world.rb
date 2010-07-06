$: << File.join(File.dirname(__FILE__), '../../lib')
require 'sweet/gtk2'
Sweet.set_debug

Sweet.app 'My first Application',  :border_width => 10 do
  flow do
    label 'Your name:'
    @name = edit_line :columns => 10

    button 'Push me' do
      puts "Hello, #{@name.text}!"
    end
  end
end
