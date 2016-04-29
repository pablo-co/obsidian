require_relative 'strategy'

module Obsidian
  module Memory
    # A {Strategy} implementation that selects the smallest available space
    # that fits a certain size
    class BestFitStrategy < Strategy
      # (see Strategy#next_space_available)
      def next_space_available(spaces, size)
        spaces_big_enough = spaces.delete_if { |space| space.size < size }
        smallest_space(spaces_big_enough)
      end

      private

      def smallest_space(spaces)
        spaces.min_by { |space| space.size }
      end
    end
  end
end
