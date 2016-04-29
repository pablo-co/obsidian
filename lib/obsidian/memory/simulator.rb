module Obsidian
  module Memory
    # Simulates memory management tasks in an OS with a given
    # {Trace}. It selects the order in which tasks are assigned memory
    # space and makes use of a {Strategy} to determine memory management
    # policies.
    # @see Strategy, Trace
    class Simulator
      # @return [Strategy] an implementation of {Strategy} which selects
      #   spaces according to some policy.
      attr_accessor :strategy

      # @return [ArrayList<Task>] the list of tasks that were allocated
      #    a space in memory
      attr_reader :tasks

      # @return [ArrayList<Task>] the list of blocked tasks that didn't
      #    fit in memory.
      attr_reader :blocked_tasks

      def initialize(strategy)
        self.strategy = strategy
        self.tasks = []
        self.blocked_tasks = []
      end

      # It takes in a {Trace} and simulates memory management with the
      # given {#strategy}.
      # @param trace [Trace] the trace to simulate
      # @return [nil]
      def process_trace(trace)
        pending_tasks = trace.tasks.dup
        spaces = trace.mem_spaces.dup
        pending_tasks.size.times do
          self.tasks << process_next_task(pending_tasks, spaces)
        end
        self.blocked_tasks = trace.tasks - tasks
      end

      private

      attr_writer :tasks
      attr_writer :blocked_tasks

      # It selects the next task to process through {#next_process_in_time}
      # and finds a space for it to occupy
      # @return [Task, nil] the task within a given memory space, nil if
      #   it space couldn't be found.
      def process_next_task(tasks, spaces)
        task = next_process_in_time(tasks)
        return nil unless task
        space = next_space_available(spaces, task.mem_size)
        task_occupies_space(task, space)
        space ? task : nil
      end

      # Searches the next process that should be have it's memory
      # allocated and removes it from the pending tasks pool.
      # @param [ArrayList<Task>] the pool of tasks
      # @return [Task, nil] the selected task, nil if there are no
      #   tasks left to select
      def next_process_in_time(tasks)
        task = smallest_task(tasks)
        tasks.delete(task)
        task
      end

      # Returns the task with the lowest arrival time from a given
      # pool of tasks.
      # @param tasks [ArrayList<Task>] the pool of tasks
      # @return [Task] the task with the lowest arrival time
      def smallest_task(tasks)
        tasks.min_by { |task| task.arrival_time }
      end

      # Removes the needed space of a given {Space} and assigns it to
      # the given {Task}.
      # @param task [Task] the task to assign space to
      # @param space [Space] the space to take memory from
      # @return [nil]
      def task_occupies_space(task, space)
        return unless space
        task.mem_space = Space.new(space.address, task.mem_size)
        space.address += task.mem_size
      end

      private

      # Returns the next space available given a set of spaces and a
      # specific size. It makes use of {Strategy#next_space_available}
      # to determine the next space.
      # @param spaces [ArrayList<Space>] the list of available spaces
      # @param size [Integer] the size that is going to be searched for
      # @return [Space, nil] returns the selected memory space, nil if
      #   not space fit.
      def next_space_available(spaces, size)
        strategy.next_space_available(spaces, size)
      end
    end
  end
end
