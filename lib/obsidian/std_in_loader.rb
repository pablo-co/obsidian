module Obsidian
  # A {Loader} implementation for loading PCBs from
  # standard user input. It asks the user for the value
  # of each attribute of the {PCB}.
  class StdInLoader < Loader

    # @return [Array<Symbol>] an array of attribute values to obtain from the user
    ATTRIBUTES = [
        :priority,
        :task
    ]

    # (see Loader#load)
    def load(_data = {})
      info = {}
      ATTRIBUTES.each do |key|
        print "#{key}: "
        info[key] = get_value
      end
      info
    end

    private

    # Obtains a string from the standard input. If it is
    # a number it will automatically return it as an Integer.
    # @return [String, Integer] the user input
    def get_value
      line = STDIN.gets.strip
      Integer(line) rescue line
    end
  end
end