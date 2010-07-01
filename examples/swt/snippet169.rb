$: << File.join(File.dirname(__FILE__), '../../lib')
require 'sweet/swt'

#	Display display = new Display ();
#	final Shell shell = new Shell (display);
#	shell.setLayout (new FillLayout ());
Sweet.app :layout => :fill do

  #	Listener listener = new Listener () {
  #		public void handleEvent (Event e) {
  #			Control [] children = shell.getChildren ();
  #			for (int i=0; i<children.length; i++) {
  #				Control child = children [i];
  #				if (e.widget != child && child instanceof Button && (child.getStyle () & SWT.TOGGLE) != 0) {
  #					((Button) child).setSelection (false);
  #				}
  #			}
  #			((Button) e.widget).setSelection (true);
  #		}
  #	};
  @listener = proc do |e|
    shell.children.each do |child|
      if e.widget != child && child.is_a?(widgets::Button) && (child.style & swt::TOGGLE)
        child.selection = false
      end
    end
    e.widget.selection = true
  end

  #	for (int i=0; i<20; i++) {
  #		Button button = new Button (shell, SWT.TOGGLE);
  #		button.setText ("B" + i);
  #		button.addListener (SWT.Selection, listener);
  #		if (i == 0) button.setSelection (true);
  #	}

  20.times do |i|
    button "B#{i}", :style => swt::TOGGLE, :selection => i == 0, &@listener
  end

  #	shell.pack ();
  #	shell.open ();
  #	while (!shell.isDisposed ()) {
  #		if (!display.readAndDispatch ()) display.sleep ();
  #	}
  #	display.dispose ();
end