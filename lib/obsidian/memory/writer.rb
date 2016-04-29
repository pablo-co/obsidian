module Obsidian
  module Memory
    # Writer is a content formatter and file writing facility that takes
    # information regarding a {Simulator} run and writes it to an output
    # file.
    class Writer
      def initialize(args = {})
        self.strategy = args.fetch(:strategy)
        self.tasks = args.fetch(:tasks)
        self.blocked_tasks = args.fetch(:blocked_tasks)
        self.mem_size = args.fetch(:mem_size)
      end

      # Dumps the results of calling {#content} to a given file.
      # @param file [String] the file where contents will be dumped
      # @return [nil]
      def write(file)
        File.write(file, content)
      end

      protected

      # @return [Strategy] the strategy used during the simulation
      attr_accessor :strategy

      # @return [ArrayList<Task>] the list of tasks who were able to be
      #   executed
      attr_accessor :tasks

      # @return [ArrayList<Task>] the list of bloked tasks due to lack of
      #   memory space
      attr_accessor :blocked_tasks

      # @return [Integer] the size of the simulation's memory
      attr_accessor :mem_size

      private

      def content
        "Algorithm: #{class_name(strategy)}\n" +
        "Assigned processes: #{tasks_content(tasks)}\n" +
        "Blocked processes: #{blocked_tasks_content(blocked_tasks)}\n" +
        "Memory utilization: #{memory_content(tasks, mem_size)}\n" +
        "Blocking probability: #{blocking_content(tasks.size, blocked_tasks.size)}\n"
      end

      # Builds a string that represents all executed tasks
      # @param tasks [arraylist<task>] the list of tasks
      # @return [String] the string representation of the tasks
      def tasks_content(tasks)
        (tasks.map { |task| task_content(task) }).join('; ')
      end

      # Builds a string that represents a given task
      # @param task [Task] the task to build the string from
      # @return [String] the string representation of the task
      def task_content(task)
        "#{task.pid}, #{task.mem_space.address}, #{task.mem_space.size}"
      end

      # Builds a string that represents all blocked tasks
      # @param tasks [arraylist<task>] the list of tasks
      # @return [String] the string representation of the tasks
      def blocked_tasks_content(blocked_tasks)
        (blocked_tasks.map { |task| blocked_task_content(task) }).join(', ')
      end

      # Builds a string that represents a given blocked task
      # @param task [Task] the task to build the string from
      # @return [String] the string representation of the task
      def blocked_task_content(task)
        "#{task.pid}"
      end

      # Builds a string about the memory usage of tasks within
      # the total available space
      # @param tasks [ArrayList<Task>] the executed tasks
      # @param mem_size [Integer] total available memory
      # @return [String] the string representation
      def memory_content(tasks, mem_size)
        tasks_memory = tasks_memory_usage(tasks)
        "#{tasks_memory} / #{mem_size} = " +
        "#{percentage(tasks_memory.to_f / mem_size)}"
      end

      # Builds a string about the blocking probability for the
      # given simulation
      # @param tasks_size [Integer] the number of executed tasks
      # @param blocked_tasks_size [Integer] the number of blocked tasks
      # @return [String] the string representation
      def blocking_content(tasks_size, blocked_tasks_size)
        probability = blocked_tasks_size.to_f / (tasks_size + blocked_tasks_size)
        "#{tasks_size} / #{blocked_tasks_size} = #{percentage(probability)}"
      end

      # Calculates the total memory size of a set of tasks
      # @param tasks [ArrayList<Task>] the set of tasks
      # @return [Integer] the sum of their memory sizes
      def tasks_memory_usage(tasks)
        (tasks.map { |task| task.mem_size }).inject(:+)
      end

      # Returns the string representation of a class without
      # it's namespace or modules.
      # @param obj [Object] the object to get the class from
      # @return [String] the class' name
      def class_name(obj)
        obj.class.to_s.split('::').last
      end

      # Returns the percentage string representation of a number
      # @param num [Number] the number
      # @return [String] the percentage representation
      def percentage(num)
        "#{num * 100.0}%"
      end
    end
  end
end
