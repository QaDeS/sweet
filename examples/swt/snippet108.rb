$: << File.join(File.dirname(__FILE__), '../../lib')
require 'sweet/swt'

#	Display display = new Display ();
#	Shell shell = new Shell (display);
#	shell.setLayout (new RowLayout ());
Sweet.app :layout => :row do

  #	Label label = new Label (shell, SWT.NONE);
  #	label.setText ("Enter your name:");
  label 'Enter your name:'

  #	Text text = new Text (shell, SWT.BORDER);
  #	text.setLayoutData (new RowData (100, SWT.DEFAULT));
  edit_line :style => swt::BORDER, :row_data => 100

  #	Button ok = new Button (shell, SWT.PUSH);
  #	ok.setText ("OK");
  #	ok.addSelectionListener(new SelectionAdapter() {
  #		public void widgetSelected(SelectionEvent e) {
  #			System.out.println("OK");
  #		}
  #	});
  button 'OK' do
    puts 'OK'
  end

  #	Button cancel = new Button (shell, SWT.PUSH);
  #	cancel.setText ("Cancel");
  #	cancel.addSelectionListener(new SelectionAdapter() {
  #		public void widgetSelected(SelectionEvent e) {
  #			System.out.println("Cancel");
  #		}
  #	});
  #	shell.setDefaultButton (cancel);
  self.default_button = button 'Cancel' do
    puts 'Cancel'
  end
  
  #	shell.pack ();
  #	shell.open ();
  #	while (!shell.isDisposed ()) {
  #		if (!display.readAndDispatch ()) display.sleep ();
  #	}
  #	display.dispose ();
end