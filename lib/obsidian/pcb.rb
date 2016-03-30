require_relative 'task'
require_relative 'track_attributes'

module Obsidian
  # A Obsidian::PCB is the representation of a task in Obsidian, it tracks information regarding
  # the running task and logging information.
  # @see Obsidian::Task
  class PCB
    include TrackAttributes

    # @return [Float] the factor by which the burst_estimate averages new values versus old ones
    AVERAGING_FACTOR = 0.5

    # @return [Integer] the current pid value, used to generate a sequence for each new task
    @@last_pid = 0

    # @return [SysCall, nil] information regarding the last system call
    attr_accessor :sys_call

    # @return [Integer] the unique identifier assigned to this task
    attr_reader :pid

    # @return [Time] the moment this task was created
    attr_reader :created_at

    # @return [Float] the current estimate of burst duration in milliseconds
    attr_reader :burst_estimate

    # @return [Float] amount of milliseconds spent running on the CPU
    attr_reader :cpu_time

    # @return [Task] the actual instance of the task running
    attr_reader :task

    def initialize(args = {})
      defaults.merge!(args).each do |key, value|
        self.send("#{key}=", value)
      end
      generate_pid
    end

    # Creates and sets a new {Task} from a given file. The file should be executable
    # Ruby code.
    # @param file [String] the file name of the executable to load
    # @return [Task] the task loaded from the file
    def task=(file)
      code = File.open(file, 'rb').read
      @task = Obsidian::Task.new(code)
    end

    # Add to the stats a new burst time, it updates the {#cpu_time}
    # and {#burst_estimate}
    # @param burst [Float] the time in milliseconds of the new burst
    # @return [nil]
    def add_last_burst(burst)
      self.cpu_time += burst
      self.burst_estimate = new_burst_estimate(burst)
    end

    # Builds a string with all attribute name's and values in this
    # instance
    # @return [String] a representation of all data in this instance
    def stats
      result = ''
      attr_accessors.each do |attr|
        result += "#{attr} #{send(attr)}\n"
      end
      result
    end

    def to_s
      "(#{pid} | #{priority} | #{cpu_time} | #{created_at})"
    end

    protected

    # @return [Integer] the priority of the given task, signaling it's execution importance over other tasks
    attr_accessor :priority

    # (see #pid)
    attr_writer :pid

    # (see #burst_estimate)
    attr_writer :burst_estimate

    # (see #created_at)
    attr_writer :created_at

    # (see #cpu_time)
    attr_writer :cpu_time

    def defaults
      {
          created_at: Time.now,
          cpu_time: 0,
          burst_estimate: 0,
          priority: 1
      }
    end

    # Assign a new pid to the current task while updating the value
    # of the shared @@last_pid class variable.
    # @note Using class instance variables is not thread safe
    # @return [nil]
    def generate_pid
      self.pid = @@last_pid
      @@last_pid += 1
    end

    # Calculates the new value of the {#burst_estimate} given a new burst value.
    # It uses AVERAGING_FACTOR to know how important are historical burst values
    # versus the last value.
    # @param last_burst [Float] the new burst time
    # @return [nil]
    def new_burst_estimate(last_burst)
      (burst_estimate * AVERAGING_FACTOR) + (last_burst * (1.0 - AVERAGING_FACTOR))
    end
  end
end