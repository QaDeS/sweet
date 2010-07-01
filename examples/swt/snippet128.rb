$: << File.join(File.dirname(__FILE__), '../../lib')
require 'sweet/swt'

#   Display display = new Display();
#		final Shell shell = new Shell(display);
#		GridLayout gridLayout = new GridLayout();
#		gridLayout.numColumns = 3;
#		shell.setLayout(gridLayout);
Sweet.app :layout => :grid.conf(:numColumns => 3) do

  #		ToolBar toolbar = new ToolBar(shell, SWT.NONE);
  #		GridData data = new GridData();
  #		data.horizontalSpan = 3;
  #		toolbar.setLayoutData(data);
  tool_bar :grid_data => {:span => 3} do

    #		ToolItem itemBack = new ToolItem(toolbar, SWT.PUSH);
    #		itemBack.setText("Back");
    #		ToolItem itemForward = new ToolItem(toolbar, SWT.PUSH);
    #		itemForward.setText("Forward");
    #		ToolItem itemStop = new ToolItem(toolbar, SWT.PUSH);
    #		itemStop.setText("Stop");
    #		ToolItem itemRefresh = new ToolItem(toolbar, SWT.PUSH);
    #		itemRefresh.setText("Refresh");
    #		ToolItem itemGo = new ToolItem(toolbar, SWT.PUSH);
    #		itemGo.setText("Go");
    #		/* event handling */
    #		Listener listener = new Listener() {
    #			public void handleEvent(Event event) {
    #				ToolItem item = (ToolItem)event.widget;
    #				String string = item.getText();
    #				if (string.equals("Back")) browser.back();
    #				else if (string.equals("Forward")) browser.forward();
    #				else if (string.equals("Stop")) browser.stop();
    #				else if (string.equals("Refresh")) browser.refresh();
    #				else if (string.equals("Go")) browser.setUrl(location.getText());
    #		   }
    #		};
    #		itemBack.addListener(SWT.Selection, listener);
    #		itemForward.addListener(SWT.Selection, listener);
    #		itemStop.addListener(SWT.Selection, listener);
    #		itemRefresh.addListener(SWT.Selection, listener);
    #		itemGo.addListener(SWT.Selection, listener);
    %w{Back Forward Stop Refresh}.each do |caption|
      tool_item(caption) { @browser.send(caption.downcase) }
    end
    tool_item('Go') { @browser.setUrl @location.text }
  end

  #		Label labelAddress = new Label(shell, SWT.NONE);
  #		labelAddress.setText("Address");
  label 'Address'

  #		final Text location = new Text(shell, SWT.BORDER);
  #		data = new GridData();
  #		data.horizontalAlignment = GridData.FILL;
  #		data.horizontalSpan = 2;
  #		data.grabExcessHorizontalSpace = true;
  #		location.setLayoutData(data);
  #		location.addListener(SWT.DefaultSelection, new Listener() {
  #			public void handleEvent(Event e) {
  #				browser.setUrl(location.getText());
  #			}
  #		});
  @location = edit_line :grid_data => {:align => :fill, :span => 2, :grab => true} do
    @browser.setUrl @location.text
  end


  #		final Browser browser;
  #		try {
  #			browser = new Browser(shell, SWT.NONE);
  #		} catch (SWTError e) {
  #			System.out.println("Could not instantiate Browser: " + e.getMessage());
  #			display.dispose();
  #			return;
  #		}
  begin
    #		data = new GridData();
    #		data.horizontalAlignment = GridData.FILL;
    #		data.verticalAlignment = GridData.FILL;
    #		data.horizontalSpan = 3;
    #		data.grabExcessHorizontalSpace = true;
    #		data.grabExcessVerticalSpace = true;
    #		browser.setLayoutData(data);
    @browser = browser :grid_data => {
      :align => [:fill, :fill],
      :span => 3,
      :grab => [true, true]
    }
  rescue org.eclipse.swt.SWTError => e
    SYSERR.puts "Could not instantiate Browser: #{e.message}"
    exit
  end

  #		final Label status = new Label(shell, SWT.NONE);
  #		data = new GridData(GridData.FILL_HORIZONTAL);
  #		data.horizontalSpan = 2;
  #		status.setLayoutData(data);
  @status = label :grid_data => {:span => 2, :align => :fill}

  #		final ProgressBar progressBar = new ProgressBar(shell, SWT.NONE);
  #		data = new GridData();
  #		data.horizontalAlignment = GridData.END;
  #		progressBar.setLayoutData(data);
  @progress_bar = progress :grid_data => {:align => :end}

  #
  #		browser.addProgressListener(new ProgressListener() {
  #			public void changed(ProgressEvent event) {
  #					if (event.total == 0) return;
  #					int ratio = event.current * 100 / event.total;
  #					progressBar.setSelection(ratio);
  #			}
  #			public void completed(ProgressEvent event) {
  #				progressBar.setSelection(0);
  #			}
  #		});
  @browser.on_progress_changed do |event|
    if event.total != 0
      @progress_bar.fraction = event.current.to_f / event.total
    end
  end
  @browser.on_progress_completed do
    @progress_bar.selection = 0
  end
  
  #		browser.addStatusTextListener(new StatusTextListener() {
  #			public void changed(StatusTextEvent event) {
  #				status.setText(event.text);
  #			}
  #		});
  @browser.on_status_text do |event|
    @status.text = event.text
  end

  #		browser.addLocationListener(new LocationListener() {
  #			public void changed(LocationEvent event) {
  #				if (event.top) location.setText(event.location);
  #			}
  #			public void changing(LocationEvent event) {
  #			}
  #		});
  @browser.on_location_changed do |event|
    @location.text = event.location if event.top
  end

  #		shell.open();
  #		browser.setUrl("http://eclipse.org");
  @browser.setUrl "http://eclipse.org"

  #
  #		while (!shell.isDisposed()) {
  #			if (!display.readAndDispatch())
  #				display.sleep();
  #		}
  #		display.dispose();
end