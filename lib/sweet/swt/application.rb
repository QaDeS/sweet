module Sweet::Application

  def perform(&block)
    display.syncExec block
  end

  def busy(&block)
    Thread.new do
      perform do
        custom::BusyIndicator.showWhile(display) do
          block.call
        end
      end
    end
  end

end
