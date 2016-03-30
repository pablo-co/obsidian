module Obsidian
  # A {Scheduler} implementation for scheduling tasks
  # according to it's estimated burst time. It selects
  # the task with the lowest burst_estimate.
  # @note It assumes the tasks respond to the burst_estimate message
  class SJFScheduler < Scheduler
    # (see Scheduler#schedule_next)
    def schedule_next(queue)
      task = get_task_by_burst(queue)
      remove_task(queue, task)
      task
    end

    private

    def get_task_by_burst(queue)
      task = nil
      queue.for_each do |data|
        task = data if task.nil? || data.burst_estimate < task.burst_estimate
      end
      task
    end

    def remove_task(queue, task)
      queue.delete_if { |data| data == task }
    end
  end
end