require_relative 'trace'
require_relative 'space'
require_relative 'task'

module Obsidian
  module Memory
    # Parser is a file parsing facility that takes in a memory trace file and
    # outputs an instance of {Trace}.
    # @see Trace
    class Parser
      # It parses a given file and builds a {Trace}.
      # @param file_name [String] the file to parse
      # @return [Trace] the parsed trace
      def parse(file_name)
        lines = []
        File.foreach(file_name) do |line|
          lines << clean_line(line)
        end
        build_trace(lines)
      end

      private

      # It builds a {Trace} from a given array of lines containing
      # information about the trace's memory size, spaces and tasks.
      # @param lines [ArrayList<String>] the lines to parse
      # @return [Trace] the parsed trace
      def build_trace(lines)
        trace = Trace.new(nil, [], [])
        trace.mem_size = parse_memory(lines)
        trace.mem_spaces = parse_spaces(lines)
        trace.tasks = parse_tasks(lines)
        trace
      end

      # Cleans up a line of leading and trailing spaces
      # @param line [String] the line to clean
      # @return [String] the cleaned line
      def clean_line(line)
        line.strip
      end

      # Returns a number in case the next line contains one
      # @note it removes the next line from the lines array
      # @param lines [ArrayList<String>] the lines
      # @return [Integer, nil] the number found in the first line
      def get_number(lines)
        lines.shift.to_i
      end

      # Slices a given number of lines out of the original pool
      # @param lines [ArrayList<String>] the pool of lines
      # @param number [Integer] the number of lines to slice
      # @return [ArrayList<String>] the lines sliced
      def next_lines(lines, number)
        lines.slice!(0, number)
      end

      # Gets the number of memory spaces there are
      # @param lines [ArrayList<String>] the pool of lines
      # @return [Integer] the number of spaces
      def parse_memory(lines)
        get_number(lines)
      end

      # Parses a pool of lines building {Space} objects for
      # each line.
      # @param lines [ArrayList<String>] the pool of lines
      # return [ArrayList<Space>] the built spaces
      def parse_spaces(lines)
        number_spaces = get_number(lines)
        space_lines = next_lines(lines, number_spaces)
        space_lines.map { |line| parse_space(line) }
      end

      # Builds a {Space} object from a string of comma separated
      # attributes.
      # @param line [String] the line with the attributes
      # @return [Space] the build space
      def parse_space(line)
        values = line.split(',')
        Space.new(values[0].to_i, values[1].to_i)
      end

      # Parses a pool of lines building {Task} objects for
      # each line.
      # @param lines [ArrayList<String>] the pool of lines
      # return [ArrayList<Task>] the built spaces
      def parse_tasks(lines)
        number_tasks = get_number(lines)
        task_lines = next_lines(lines, number_tasks)
        task_lines.map { |line| parse_task(line) }
      end

      # Builds a {Task} object from a string of comma separated
      # attributes.
      # @param line [String] the line with the attributes
      # @return [Task] the build space
      def parse_task(line)
        values = line.split(',')
        Task.new(
          pid: values[0].to_i,
          arrival_time: values[1].to_i,
          duration: values[2].to_i,
          mem_size: values[3].to_i
        )
      end
    end
  end
end
