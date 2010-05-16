require 'sweet/downloader'

describe Downloader, '#system_qualifier' do
  before :each do
    @d = Downloader.new
  end

  it 'returns gtk-linux-x86 for Linux i686' do
    @d.system_qualifier(:os => 'Linux', :arch => 'i686').should == 'gtk-linux-x86'
  end

  it 'returns gtk-linux-x86 for Linux x86_64' do
    @d.system_qualifier(:os => 'Linux', :arch => 'x86_64').should == 'gtk-linux-x86_64'
  end

  it 'returns motif-linux-x86 for Linux i686 and :tk => "motif"' do
    @d.system_qualifier(:os => 'Linux', :arch => 'i686', :tk => 'motif').should == 'motif-linux-x86'
  end

  it 'returns cocoa-macos for Mac OS X i686' do
    @d.system_qualifier(:os => 'Mac OS X', :arch => 'i686').should == 'cocoa-macosx'
  end

  it 'returns cocoa-macos-x86_64 for Mac OS X x86_64' do
    @d.system_qualifier(:os => 'Mac OS X', :arch => 'x86_64').should == 'cocoa-macosx-x86_64'
  end

  it 'returns win32-win32-x86 for Windows XP' do
    @d.system_qualifier(:os => 'Windows XP', :arch => 'i686').should == 'win32-win32-x86'
  end

  it 'returns win32-win32-x86_64 for Windows Vista on x86_64' do
    @d.system_qualifier(:os => 'Windows Vista', :arch => 'x86_64').should == 'win32-win32-x86_64'
  end

end