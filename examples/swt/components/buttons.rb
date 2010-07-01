class Buttons < AlignableTab
  title "Buttons"

  def alignment_group(listener)
    radio_button 'Up', &listener
    radio_button 'Down', &listener
  end

  def example_group
    # TODO densify with :grid_data => [:fill_both, :grab_both] or alike
    group_layout = {:layout => :grid.conf(:numColumns => 3), :grid_data => {:align => [:fill, :fill], :grab => [true, true]}}

    @text_buttons = group('Text Buttons', group_layout)
    @image_buttons = group('Image Buttons', group_layout)
    @image_text_buttons = group('Image Text Buttons', group_layout)
  end

  def example_widgets(style)
    [ #returns all created widgets
      @text_buttons.append do
        %w{One Two Three}.map { |caption| button caption, :style => style }
      end,
      @image_buttons.append do
        # TODO images
        %w{One Two Three}.map { |type| button type, :style => style }
      end,
      @image_text_buttons.append do
        # TODO images
        %w{One Two Three}.map { |type| button type, :style => style }
      end
    ].map(&:children)
  end

end

