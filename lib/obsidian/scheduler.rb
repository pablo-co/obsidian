module Obsidian
  # An job scheduler which selects the next task
  # to execute from a given queue
  # @see SJFScheduler for reference implementation
  # @abstract - subclass and implement {#schedule_next}.
  class Scheduler
    # Return next task to schedule
    # @param [List] queue the queue which the task to schedule next
    # @return [PCB] the selected task
    # @raise [StandardError] if {#schedule_next} is not implemented
    def schedule_next(queue)
      raise StandardError.new('Scheduler#schedule_next is not implemented')
    end
  end
end