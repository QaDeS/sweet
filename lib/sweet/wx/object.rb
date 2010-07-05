class Wx::Object
  include Sweet::Component

  def handle_event(evt, &block)
    send evt, get_id do |event|
      block.call
    end
  end

  def layout=(layout)
    l = case layout
    when :flow
      Wx::BoxSizer.new(Wx::HORIZONTAL)
    when :stack
      Wx::BoxSizer.new(Wx::VERTICAL)
    end
    set_sizer l
  end
end
