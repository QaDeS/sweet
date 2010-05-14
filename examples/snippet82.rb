$: << File.join(__FILE__, '../lib')
require 'sweet'

#Display display = new Display();
#	Shell shell = new Shell(display);
#	shell.setLayout(new FillLayout());
Sweet.app :layout => :fill do

  #	CTabFolder folder = new CTabFolder(shell, SWT.BORDER);
  @folder = tab_folder do
    #	for (int i = 0; i < 4; i++) {
    #		CTabItem item = new CTabItem(folder, SWT.CLOSE);
    #		item.setText("Item "+i);
    #		Text text = new Text(folder, SWT.MULTI);
    #		text.setText("Content for Item "+i);
    #		item.setControl(text);
    #	}
    4.times do |i|
      tab_item "Item #{i}", :control => edit_area("Content for Item #{i}")
    end

    #	final CTabItem specialItem = new CTabItem(folder, SWT.CLOSE);
    #	specialItem.setText("Don't Close Me");
    #	Text text = new Text(folder, SWT.MULTI);
    #	text.setText("This tab can never be closed");
    #	specialItem.setControl(text);
    @special_item = tab_item("Don't Close Me", :control => edit_area("This tab can never be closed"))
    
    #	final CTabItem noCloseItem = new CTabItem(folder, SWT.NONE);
    #	noCloseItem.setText("No Close Button");
    #	Text text2 = new Text(folder, SWT.MULTI);
    #	text2.setText("This tab does not have a close button");
    #	noCloseItem.setControl(text2);
    tab_item "No Close Button", :style => :none, :control => edit_area("This tab does not have a close button")
  end
  
  #	folder.addCTabFolder2Listener(new CTabFolder2Adapter() {
  #		public void close(CTabFolderEvent event) {
  #			if (event.item.equals(specialItem)) {
  #				event.doit = false;
  #			}
  #		}
  #	});
  @folder.on_close do |event|
    event.doit = event.item != @special_item
  end

  #	shell.pack();
  #	shell.open();
  #	while (!shell.isDisposed()) {
  #		if (!display.readAndDispatch())
  #			display.sleep();
  #	}
  #	display.dispose();
end