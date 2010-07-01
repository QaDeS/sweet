$: << File.join(File.dirname(__FILE__), '../../lib')
require 'sweet/swt'

class Tab < Java::OrgEclipseSwtCustom::CTabItem
  def self.title(title = nil)
    title ? instances[@title = title] = self : @title
  end
  def self.instances
    @instances ||= {}
  end

  def create
    var_container!
    @style = 0
    group :layout => :grid, :grid_data => {:align => [:fill, :fill], :grab => [true, true]} do
      create_example_group
    end
    group 'Parameters', :layout => :grid, :grid_data => {:align => [:fill, :fill]} do
      create_parameter_group
    end
  end

  def create_example_group
    example_layout = 
    @example_group = group('Examples', example_layout) do
      example_groups if respond_to? :example_group
    end
    @parameters_group =
    create_example_widgets
  end

  def create_example_widgets
    if widgets = @example_widgets
      widgets.each { |widget| widget.dispose }
    end
    @example_widgets = example_widgets.flatten
    # TODO hook listener and set state
    @example_widgets.each do |widget|
      widget.alignment = widget_alignment
      widget.visible = true
    end
  end

  def create_style_group
    listener = proc { |event|
      if event.widget.selection
        self.widget_style = event.widget
        create_example_widgets
      end
    }

    @style_group = group('Styles', :grid_data => {:align => [:fill, :fill]}) do
      %w{PUSH CHECK RADIO TOGGLE}.each{ |type| radio_button type, &listener}
      %w{FLAT BORDER}.each{ |type| check_button type, &listener}
    end
  end

  def widget_style
    @style ||= 0
  end
  def widget_style=(value)
    @style = value
  end
end

class AlignableTab < Tab
  def create_alignment_group
    listener = proc { |event|
      if event.widget.selection
        self.widget_alignment = event.widget
        create_example_widgets
      end
    }

    group = @parent.append{ group('Alignment', :layout => :grid, :grid_data => {:align => [:fill, :fill]}) }
    group.append do
      radio_button 'Left', :selection => true, &listener
      radio_button 'Center', &listener
      radio_button 'Right', &listener
    end

    alignment_group(group, listener) if respond_to? :alignment_group
  end

  def widget_alignment
    @widget_alignment ||= 0
  end
  def widget_alignment=(value)
    @widget_alignment |= value.text.to_sym.swt_const
  end
  def widget_style
    super | widget_alignment
  end
end

Dir.glob(File.join(File.dirname(__FILE__), 'components/*.rb')).each{|file| load file}


Sweet.app 'Component DEMO', :layout => :fill do

  tab_folder do
    tab_item Buttons::title do
      @parent_tab = composite(:layout => :grid.conf(:numColumns => 3))
    end
    buttons = Buttons.new(@parent_tab, swt::CLOSE)

    buttons.create_alignment_group
    buttons.create_example_group
    buttons.create_style_group
  end

end

