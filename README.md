# Obsidian

Obsidian is a simulated OS written in ruby that supports process and resource managemen. It's easy to write your own tasks and scheduling algorithms


## Installation

In case of not having ruby installed in your system refer to [ruby install](https://www.ruby-lang.org/en/documentation/installation/).

Clone this repository:

```
git clone https://github.com/pablo-co/obsidian
```

And then execute:

    $ bin/setup

## Usage

### Running the CLI

Obsidian comes bundled with a CLI. To run this CLI:

Assuming you are on the root of the project
```
bin/console
```

A prompt should be shown.

```
obsidian >> |
```

### Using the CLI

You can run many commands on the CLI with the following format: `command argument1 argument2 ...`. To see all valid commands and their usage run `help`.

```
obsidian >> help
Usage: command argument1 argument2 ...
Options:
  help                                   Display this message
  load_task_from_file [file]             Load a task from a given YAML file
  load_task_from_std_in                  Load a task from standard input
  load_module [file]                     Load a Ruby file into memory
  remove_task [pid]                      Remove a task from the ready queue
  get_task_stats [pid]                   List all information of a task
  set_scheduler [scheduler class]        Sets the scheduling algorithm
  set_running_time [time]                Set Q in for scheduling policies
  set_output_delay [delay]               Set a delay for writing to the output device
  set_automatic_scheduling [true|false]  Schedule jobs automatically
  step                                   Run the scheduler and dispatcher once
  steps [times]                          Run the scheduler and dispatcher n times
  queues                                 Prints the contents of all queues
  set_memory_strategy [strategy class]   Sets the memory strategy algorithm
  process_memory_trace [input] [output]  Processes a memory trace and outputs the result to a file

Bug reports, suggestions, updates:
https://github.com/pablo-co/obsidian/issues
```

#### Load a task

You can load tasks from a file and from standard input. In both cases the user defined attributes are:
* priority: The task scheduling priority, it's importance depends on the scheduling algorithm.
* task: The file with the code that will be executed.

__Loading a task from a file__
```
obsidian >> load_task_from_file example_file.yml
```

The file format is exclusively [YAML](http://yaml.org/). The keys in the file are the task attributes while it's values are well... it's values.

Example file:
```
priority: 1
task: examples/sum.rb
```


__Loading a task from standard input__

Example user input:
```
obsidian >> load_task_from_std_in
priority: 1
task: examples/sum.rb
```

#### Remove a task

You can remove a task by specifying it's pid.
Note: For consistency purposes you can only remove tasks that are in the ready queue.

```
obsidian >> remove_task [pid]
```

#### Print task stats

You can print all the attributes for a given task to the console.

```
obsidian >> get_task_stats [pid]
```

#### Print the scheduling queues

You can print all the scheduling queues with their corresponding tasks.

```
obsidian >> queues
```

#### Change the scheduling algorithm

You can change and even write your own scheduling algorithm. To change the algorithm you need to specify the class of this algorithm.

The built-in classes are:
* Obsidian::RoundRobinScheduler (Default)
* Obsidian::SJFScheduler (Schedules according to estimated burst time)
* Obsidian::PrioritySJFScheduler (Schedules according to priority)

```
obsidian >> set_scheduler Obsidian::SJFScheduler
```

To write your own algorithm see [Scheduler](lib/obsidian/scheduler.rb)

#### Change burst time

You can change the maximum time for which a task can run (the default is 10). To remove the burst time limit write `infinity`, this will effectively make all scheduling non-preemptive.

To set Q to 10 milliseconds.
```
obsidian >> set_running_time 10
```

Remove the maximum burst time. Make all schedulers non-preemptive.
```
obsidian >> set_running_time infinity
```

#### Change output delay

To write to the standard output all programs need to call `sys.out` which will write to stdout. This system call takes the task out of the running state and into the waiting queue. The delay is the amount of simulated time it takes to write to this device (the default is 1000).

```
obsidian >> set_output_delay 1000
```

#### Change automatic scheduling

You can change whether Obsidian should automatically schedule and dispatch a task or have the user do it manually (by defaults it's true).

To enable it.
```
obsidian >> set_automatic_scheduling true
```

To disabled it.
```
obsidian >> set_automatic_scheduling false
```

#### Run the scheduler manually

You can also run the scheduler and dispatcher manually. But first you have to disable automatic scheduling.

First make sure you disable automatic scheduling.
```
obsidian >> set_automatic_scheduling false
```

Run the scheduler and dispatcher once
```
obsidian >> step
```

Run the scheduler and dispatcher `n` times.
```
obsidian >> steps n
```

#### Change the memory management strategy

You can change the memory management strategy used when processing memory
traces.

```
obsidian >> set_memory_strategy Obisidian::Memory::FirstFitStrategy
```

There are 3 built-in strategies:
* Obsidian::Memory::FirstFitStrategy
* Obsidian::Memory::BestFitStrategy
* Obsidian::Memory::WorstFitStrategy

##### Write your own memory management strategy

To write your own strategy all you have to do is write a class that is a
subclass of `Obsidian::Memory::Strategy` and that implements
`next_space_available`. See any of the built-in strategies for reference.

You first have to load your custom strategy to memory:
```
obsidian >> load_module your_custom_strategy.rb
```

And then you just set it as the current memory strategy:
```
obsidian >> set_memory_strategy YourCustomStrategy
```

#### Simulate a memory trace

You can simulate the memory management process with a memory trace file. This
file has the following format:
```
size_of_memory
number_of_available_spaces
starting_address_1, available_space_1
starting_address_2,  available_space_2 
...
starting_address_N, available_space_N
number_of_processes
pid, arrival_time, duration, size_of_memory
pid, arrival_time, duration, size_of_memory
...
pid, arrival_time, duration, size_of_memory
```

See `examples/memory_trace.txt` for an example memory trace.

To simulate the memory trace:
```
obsidian >> process_memory_trace examples/memory_trace.txt output.txt
```

This will parse the memory trace in the first file and output the result of
doing memory management with the tasks and memory state given to the output file.

The output given by the example command:
```
Algorithm: FirstFitStrategy
Assigned processes: 1, 200, 115; 2, 600, 500; 3, 1100, 358; 4, 1458, 200; 5, 1658, 375
Blocked processes: 
Memory utilization: 1548 / 4000 = 38.7%
Blocking probability: 5 / 0 = 0.0%
```

## Writing your own programs

You can run almost any type of ruby code in Obsidian. This code runs in a sandbox thus has some limitations regarding system calls in general. This means you can't make use of files, threads and any other type of operation that interfaces with the operating system.

The only system call currently supported by Obsidian is writing to stdout.

```ruby
sys.out 'Hello world!'
```

The are several examples of programs in the [examples folder](examples).

### Running the example files

You can load the example programs through the CLI to see them in action.

Currently the example programs are:
* examples/calculate_pi.yml
* examples/sum.yml
* examples/exception.yml

```
obsidian >> load_task_from_file examples/calculate_pi.yml

obsidian >>

[Output (0)]: PI ~= 4.0

[Output (0)]: PI ~= 2.666666666666667

[Output (0)]: PI ~= 3.466666666666667

[Output (0)]: PI ~= 2.8952380952380956

[Output (0)]: PI ~= 3.3396825396825403

```

## Usage examples

```
obsidian >> set_scheduler Obsidian::RoundRobinScheduler

obsidian >> set_running_time 20

obsidian >> queues

Waiting: 
Ready: 
Running: 

obsidian >> load_task_from_file examples/sum.yml

obsidian >> queues

Waiting: 
Ready: (0 | 1 | 220.64876556396484 | 2016-03-30 21:30:37 -0600)
Running: 

obsidian >> load_task_from_file examples/calculate_pi.yml

obsidian >> 
[Output (1)]: Estimating the value of PI...

[Output (1)]: PI ~= 4.0

obsidian >> queues

Waiting: (1 | 2 | 6.8798065185546875 | 2016-03-30 21:30:42 -0600)
Ready: 
Running: (0 | 1 | 1151.9584655761719 | 2016-03-30 21:30:37 -0600)

obsidian >> 
[Output (1)]: PI ~= 2.666666666666667

[Output (1)]: PI ~= 3.466666666666667

[Output (1)]: PI ~= 2.8952380952380956

[Output (1)]: PI ~= 3.3396825396825403

obsidian >> remove_task 0

obsidian >> queues

Waiting: (1 | 2 | 6.8798065185546875 | 2016-03-30 21:30:42 -0600)
Ready: 
Running:
```

## Documentation

All documentation is available online at [RubyDoc](http://www.rubydoc.info/github/pablo-co/obsidian/master)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pablo-co/obsidian. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](CODE_OF_CONDUCT.md) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

