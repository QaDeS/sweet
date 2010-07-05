module Sweet::Application
  def perform(&block)
    instance_eval &block
  end

  def busy(&block)
    Wx::BusyCursor.busy &block
  end
end
