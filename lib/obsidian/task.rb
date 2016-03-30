require_relative 'instrumentation'

module Obsidian
  # Obsidian::Task is the equivalent of a process in memory. Combined with the execution
  # control of the OS. It contains and executes the code until it's time is finished or
  # until it makes a system call.
  # @see Obsidian::PCB
  class Task
    # @return [Time] the moment at which the task was scheduled. Used for preemption
    attr_accessor :scheduled_at

    # @return [Integer] limit time in milliseconds this task can run
    attr_accessor :time

    # @return [String] instrumented code that is being run
    attr_accessor :code

    # @return [Object] an object that acts as the system calls API
    attr_accessor :sys

    # @return [Boolean] can the task continue execution? If not
    #   it means it's been preempted
    attr_accessor :can_exec

    def initialize(code)
      self.code = instrument(code)
      self.can_exec = true
    end

    # Execute the code line by line until it finishes, it's time is up or until
    # it makes a system call.
    # @return [nil]
    def execute
      self.scheduled_at = Time.now
      Kernel.loop do
        execute_next_line
        return thread.alive? unless continue_execution?
      end
    end

    # Create a separate thread in which the instrumented code will be executed
    # @return [nil]
    def thread
      @thread ||= Thread.new(sys) do |sys|
        eval(code)
      end
    end

    private

    # Instrument a given code so it can be tracked and preempted. It is
    # instrumented using {Obsidian::Instrumentation#instrument}
    # @param code [String] the code that is going to be instrumented
    # @return [String] the instrumented code
    def instrument(code)
      instrumentation = Obsidian::Instrumentation.new
      instrumentation.instrument(code)
    end

    # Execute the next line in the code if it hasn't finished
    # @return [nil]
    def execute_next_line
      thread.run if thread.alive?
    end

    # Check if the time of execution for this task has ended or if it
    # already has finished.
    # @return [Boolean] should the code continue execution?
    def continue_execution?
      (Time.now.to_f - scheduled_at.to_f) * 1000.0 < time && thread.alive? && can_exec
    end
  end
end