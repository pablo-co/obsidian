module Obsidian
  # A {Scheduler} implementation for scheduling tasks
  # in a round robin fashion.
  # @example Given a list of tasks with the following pids:
  # [15, 10, 2, 6, 1]
  # They will be scheduled in the order of appearance
  # [15, 10, 2, 6, 1]
  class RoundRobinScheduler < Scheduler
    # (see Scheduler#schedule_next)
    def schedule_next(queue)
      queue.pop
    end
  end
end