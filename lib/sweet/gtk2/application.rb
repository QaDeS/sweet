module Sweet::Application
  def perform(&block)
    # TODO implement
    instance_eval &block
  end

  def busy(&block)
    # TODO implement
    instance_eval &block
  end
end
