module Obsidian
  # A {Scheduler} implementation for scheduling tasks
  # according to it's priority. It selects the task
  # with the lowest priority value.
  # @note It assumes the tasks respond to the priority message
  class PrioritySJFScheduler < Scheduler
    # @see Scheduler#schedule_next
    def schedule_next(queue)
      task = get_task_by_priority(queue)
      remove_task(queue, task)
      task
    end

    private

    def get_task_by_priority(queue)
      task = nil
      queue.for_each do |data|
        task = data if task.nil? || data.priority < task.priority
      end
      task
    end

    def remove_task(queue, task)
      queue.delete_if { |data| data == task }
    end
  end
end