module Obsidian
  # Is a utility class which adds instrumentation code to a given file of Ruby code.
  # @see Obsidian::Task
  class Instrumentation
    def instrument(code)
      result_code = ''
      lines = code.split("\n")[0..-1]
      lines.each do |line|
        result_code += instrument_line(line)
      end
      result_code
    end

    private

    # Instrument a line of code with tracking and control code.
    # @note under some circumstances the line might be left as is
    # @param line [String] the line that is going to be instrumented
    # @return [String] the instrumented line
    def instrument_line(line)
      return line unless should_instrument_line?(line)
      "#{line}\nThread.stop\n"
    end

    # Should the current line be instrumented
    # @param line [String] the line that is going to be instrumented
    # @return [true|false] instrument the line?
    def should_instrument_line?(line)
      line.index('return').nil?
    end
  end
end