require_relative 'loader'
require_relative 'file_loader'
require_relative 'std_in_loader'
require_relative 'pcb'
require_relative 'scheduler'
require_relative 'sjf_scheduler'
require_relative 'priority_sjf_scheduler'


# Init is the entry class which serves as the API to any client
# looking to interact with the simulated OS. It makes use of
# {Obsidian::Manager} to manage tasks and settings.
# @see Obsidian::Manager
class Obsidian::Init
  # @return [Manager] the manager to submit task and actions to
  # @see Obsidian::Manager
  attr_accessor :manager

  def initialize(manager)
    self.manager = manager
  end

  # Loads a PCB from a given file and adds it to the manager's
  # tasks, it should be a YAML file.
  # @see Obsidian::FileLoader
  # @param file [String] the file name of the YAML file to load
  # @return [nil]
  def load_task_from_file(file)
    load_task(Obsidian::FileLoader.new, file: file)
  end

  # Loads a PCB from standard output and adds it to the manager's
  # tasks.
  # @see StdInLoader
  # @return [nil]
  def load_task_from_std_in
    load_task(Obsidian::StdInLoader.new)
  end

  # Removes a task from the {Obsidian::Manager}
  # (see Obsidian::Manager#remove_task)
  # @param pid [#to_i] the pid of the task to remove
  # @return [nil]
  def remove_task(pid)
    manager.remove_task(pid.to_i)
  end

  # Displays to the standard output information for a given task
  # (see Obsidian::PCB#stats)
  # @param pid [#to_i] the pid of the task to display
  # @return [nil]
  def get_task_stats(pid)
    puts manager.get_task(pid.to_i).stats
  end

  # Sets the time (Q) given to each task for each execution run.
  # @note use "infinity" to disable preemption
  # @param time [#to_i] the time in milliseconds
  # @return [nil]
  def set_running_time(time)
    if time == 'infinity'
      time = Float::INFINITY
    else
      time = time.to_i
    end
    manager.time = time
  end

  # Sets the amount of time a write to an output device
  # will take.
  # @param delay [#to_i] the delay in milliseconds
  # @return [nil]
  def set_output_delay(delay)
    manager.output_delay = delay.to_i
  end

  # Sets whether the scheduler should automatically schedule tasks
  # as they are inserted into the ready queue.
  # @param automatic [String] the boolean value for the setting. Anything other than 'true' is considered false
  # @return [nil]
  def set_automatic_scheduling(automatic)
    manager.automatic_scheduling = automatic == 'true'
  end

  # Changes the scheduler instance being used.
  # @param scheduler [String] the class name of the scheduler should subclass {Obsidian::Scheduler}
  # @return [nil]
  def set_scheduler(scheduler)
    begin
      scheduler_cls = Object.const_get(scheduler)
      raise Exception unless scheduler_cls < Obsidian::Scheduler
      manager.scheduler = scheduler_cls.new
    rescue Exception
      puts "#{scheduler} is not a valid scheduler."
    end
  end

  # Executes the scheduler and dispatch once
  # @see Obsidian::Manager#execute
  # @return [nil]
  def step
    manager.execute do
      queues
    end
  end

  # Executes the scheduler and dispatch many times. It also
  # displays the queues contents after each step
  # @see Obsidian::Manager#execute
  # @see Obsidian::Manager#display_queues
  # @param amount [#to_i] times to execute the scheduler
  # @return [nil]
  def steps(amount)
    amount.to_i.times do
      step
    end
  end

  # Displays the scheduling queues to the standard
  # output
  # @return [nil]
  def queues
    puts '(pid | priority | cpu | created_at)'
    puts manager.display_queues
  end

  # The text that should be shown to the user on the CLI
  # @return [String] the prompt to show to the user
  def prompt
    "\nobsidian >> "
  end

  # Displays a help message regarding the usage of the command line
  # to interact with this class.
  # @return [nil]
  def help
    puts <<-helpmsg
Usage: command argument1 argument2 ...
Options:
  help                                   Display this message
  load_task_from_file [file]             Load a task from a given YAML file
  load_task_from_std_in                  Load a task from standard input
  remove_task [pid]                      Remove a task from the ready queue
  get_task_stats [pid]                   List all information of a task
  set_scheduler [scheduler class]        Sets the scheduling algorithm
  set_running_time [time]                Set Q in for scheduling policies
  set_output_delay [delay]               Set a delay for writing to the output device
  set_automatic_scheduling [true|false]  Schedule jobs automatically
  step                                   Run the scheduler and dispatcher once
  steps [times]                          Run the scheduler and dispatcher n times
  queues                                 Prints the contents of all queues

Bug reports, suggestions, updates:
https://github.com/pablo-co/obsidian/issues
    helpmsg
  end

  private

  # Creates a new {Obsidian::PCB} with the given attributes
  # and adds it as a task in the {Obsidian::Manager}
  # @param [Hash] args the attributes and values of the {Obsidian::PCB}
  # @return [nil]
  def load_task(loader, args = {})
    pcb = Obsidian::PCB.new(loader.load(args))
    manager.add_task(pcb)
  end
end
