module Obsidian
  module Memory
    # A memory task is a the representation of a task in an operating system.
    # This object is only a container for information and holds no relation
    # with {Obsidian::Task}.
    class Task
      # @return [Integer] the unique identifier for this task
      attr_accessor :pid

      # @return [Integer] the arrival time to the system
      attr_accessor :arrival_time

      # @return [Integer] the execution time
      attr_accessor :duration

      # @return [Integer] amount of memory it occupies
      attr_accessor :mem_size

      # @return [Space] memory space it occupies
      attr_accessor :mem_space

      def initialize(args = {})
        self.pid = args.fetch(:pid)
        self.arrival_time = args.fetch(:arrival_time)
        self.duration = args.fetch(:duration)
        self.mem_size = args.fetch(:mem_size)
      end
    end
  end
end
