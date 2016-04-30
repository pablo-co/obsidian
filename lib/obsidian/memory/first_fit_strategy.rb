require_relative 'strategy'

module Obsidian
  module Memory
    # A {Strategy} implementation that finds the first memory space big
    # enough to fit a certain size
    class FirstFitStrategy < Strategy
      # (see Strategy#next_space_available)
      def next_space_available(spaces, size)
        spaces_big_enough = spaces.delete_if { |space| space.size < size }
        spaces_big_enough.first
      end
    end
  end
end
