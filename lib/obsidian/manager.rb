require_relative 'list'
require_relative 'sys_call'

module Obsidian
  # Obsidian::Manager is the center mastermind in this simulated OS. It is the glue
  # between all things in the system. It also plays a lot of roles that were not worth
  # separating to their own module. In general it plays the role of keeping track of
  # scheduling queues, scheduling settings, I/O and task dispatching.
  # @see Obsidian::Task
  # @see Obsidian::PCB
  # @see Obsidian::Scheduler
  class Manager
    # @return [Obsidian::Scheduler] an implementation of {Obsidian::Scheduler}
    #   which selects the next task to be executed
    attr_accessor :scheduler

    # @return [Obsidian::List] a queue with all tasks waiting for some device
    attr_accessor :waiting

    # @return [Obsidian::List] a queue of all tasks ready to be executed
    attr_accessor :ready

    # @return [Obsidian::List] a queue with all tasks that are currently running,
    #   as it stands this queue should only have one task
    attr_accessor :running

    # @return [Mutex] a mutex which controls concurrent access to the scheduling
    #   queues.
    attr_accessor :queue_m

    # @return [Float] the time a task can be in the running state
    attr_accessor :time

    # @return [Float] the delay in milliseconds for writing to an output device
    attr_accessor :output_delay

    # @return [Boolean] whether the manager should schedule tasks as soon as the
    #   running queue is empty
    attr_accessor :automatic_scheduling

    def initialize(args = {})
      self.scheduler = args.fetch(:scheduler)
      self.output_delay = args.fetch(:output_delay, 1000)
      self.time = args.fetch(:time, 100)
      self.waiting = Obsidian::List.new
      self.ready = Obsidian::List.new
      self.running = Obsidian::List.new
      self.automatic_scheduling = true
      self.queue_m = Mutex.new
      run_automatic_scheduling
      run_output_device
    end

    # Schedule and dispatch the a task. It will use {#get_next_pcb} to
    # get the next task. If there is no task to execute it exits early.
    # Calls {#end_execution} after finishing execution.
    # @return [nil]
    def execute
      pcb = get_next_pcb
      return unless pcb
      yield if block_given?
      begin
        success = false
        success = pcb.task.execute if pcb.task
        end_execution(success, pcb)
      rescue Exception => e
        puts 'Program exited with error'
        puts pcb
        running.pop
      end
    end

    # End the execution of a given task. If it finished successfully
    # then it will be pushed to the ready queue and its execution will be
    # registered in it's PCB.
    # @param success [Boolean] did the process end execution successfully
    # @param pcb [PCB] the pcb of the process that finished execution
    # @return [nil]
    def end_execution(success, pcb)
      if success
        pop_and_push(running, ready)
        register_execution_stats(pcb)
      else
        running.pop
      end
    end

    # Adds a task that should be executed
    # @param data [PCB] the task that is going to be added
    # @return [nil]
    def add_task(data)
      data.task.sys = self
      push(ready, data)
    end

    # Removes a task from the ready queue
    # @param pid [#to_i] the pid of the task to remove
    # @return [nil]
    def remove_task(pid)
      ready.delete_if { |pcb| pcb.pid == pid }
    end

    # Get the {PCB} of a given task by pid.
    # @param pid [Integer] the pid of the task
    # @return [PCB, nil] the pcb of task or nil if not found
    def get_task(pid)
      task = nil
      ready.for_each { |pcb| task = pcb if pcb.pid == pid }
      running.for_each { |pcb| task = pcb if pcb.pid == pid } unless task
      waiting.for_each { |pcb| task = pcb if pcb.pid == pid } unless task
      task
    end

    # Get a display representation of all scheduling queues.
    # @return [String] the string representation of all scheduling queues
    def display_queues
      "\nWaiting: #{waiting.to_s}\nReady: #{ready.to_s}\nRunning: #{running.to_s}\n"
    end

    # System call interface for writing to the output device. It takes the task
    # out of execution and into the waiting queue.
    # @note this should probably be extracted to it's own class but
    #   for now it's acceptable.
    # @param value [Integer] the pid of the task
    # @return [nil]
    def out(value)
      pop_and_push(running, waiting) do |pcb|
        stop_execution(pcb)
        pcb.sys_call = Obsidian::SysCall.new(type: :output, data: value)
      end
    end

    private

    # Registers a given task as in execution and sets
    # its maximum running time.
    # @param pcb [Task] the task in execution
    # @return [nil]
    def register_execution(pcb)
      return unless pcb
      push(running, pcb)
      pcb.task.time = time
    end

    # Registers the stats after a given execution in a task's {PCB}.
    # @param pcb [Task] the task that was in execution
    # @return [nil]
    def register_execution_stats(pcb)
      time_running = (Time.now.to_f - pcb.task.scheduled_at.to_f) * 1000.0
      pcb.add_last_burst(time_running)
    end

    # Preempts a task taking it out of execution. It also
    # registers the stats in the {PCB}.
    # @param pcb [Task] the task that was in execution
    # @return [nil]
    def stop_execution(pcb)
      register_execution_stats(pcb)
      pcb.task.can_exec = false
    end

    # Creates and runs a new thread which periodically checks for
    # tasks in the waiting queue. If there is a task waiting, it
    # writes to the standard output according to it's {PCB#sys_call}.
    # @return [nil]
    def run_output_device
      Thread.new {
        loop do
          sleep(output_delay / 1000.0)
          pcb = pop_and_push(waiting, ready)
          next unless pcb
          pcb.task.can_exec = true
          puts "\n[Output (#{pcb.pid})]: #{pcb.sys_call.data}\n" if pcb.sys_call.type == :output
          STDOUT.flush
        end
      }
    end

    # Creates and runs a new thread which periodically checks if
    # the running queue is empty and if automatic_scheduling is
    # enabled. If true executes the next ask in the ready queue.
    # @return [nil]
    def run_automatic_scheduling
      Thread.new {
        loop do
          sleep(0.1)
          execute if automatic_scheduling && running.empty?
        end
      }
    end

    # Returns the next task that should be executed. Makes use of
    # {Scheduler#schedule_next} to select the task.
    # @return [PCB] the selected task
    def get_next_pcb
      pcb = nil
      queue_m.synchronize do
        pcb = scheduler.schedule_next(ready)
      end
      register_execution(pcb)
      pcb
    end

    # Thread safe push to a queue
    # @param queue [List] the queue to push to
    # @param value [Object] the value to push
    # @return [nil]
    def push(queue, value)
      queue_m.synchronize do
        queue.push(value)
      end
    end

    # Thread safe pop off a queue
    # @param queue [List] the queue to pop to
    # @return [nil]
    def pop(queue)
      queue_m.synchronize do
        queue.pop
      end
    end

    # Thread safe pop and push between queues. You may pass a block
    # that evaluates the given {PCB} between the pop and push.
    # @param from [List] the queue to pop from
    # @param to [List] the queue to push to
    # @return [nil]
    def pop_and_push(from, to)
      queue_m.synchronize do
        value = from.pop
        yield value if block_given? && value
        to.push(value) if value
        value
      end
    end
  end
end
