module Obsidian
  module Memory
    # A memory management that selects an available space from a given list
    # according to some established policy
    # @see FirstFitStrategy for reference implementation
    # @abstract - subclass and implement {#next_space_available}.
    class Strategy
      # Loads the data of a new task
      # @param spaces [ArrayList<Space>] available spaces on memory
      # @param size [Integer] amount of space to find
      # @return [Space, nil] the selected space, nil when no space fits
      # @raise [StandardError] if {#next_space_available} is not implemented
      def next_space_available(spaces, size)
        raise StandardError.new('Strategy#next_space_available is not implemented')
      end
    end
  end
end
