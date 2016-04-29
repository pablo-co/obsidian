require_relative 'strategy'

module Obsidian
  module Memory
    # A {Strategy} implementation that selects the biggest available space
    # that fits a certain size
    class WorstFitStrategy < Strategy
      # (see Strategy#next_space_available)
      def next_space_available(spaces, size)
        spaces_big_enough = spaces.delete_if { |space| space.size < size }
        biggest_space(spaces_big_enough)
      end

      private

      def biggest_space(spaces)
        spaces.max_by { |space| space.size }
      end
    end
  end
end
