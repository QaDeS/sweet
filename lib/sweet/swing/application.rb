module Sweet::Application
  def perform(&block)
    SwingUtilities.invoke_and_wait block
  end

  def busy(&block)
    SwingUtilities.invoke_later_wait block
  end
end
