module Obsidian
  # It is the storage mechanism that wraps around the data being stored in
  # {Obsidian::List}. It also stores both the next and the previous nodes in the
  # sequence
  # @see Obsidian::List
  class Node
    # @return [Object, nil] the data that is being stored
    attr_accessor :data

    # @return [Obsidian::Node, nil] the next node in the sequence
    attr_accessor :next_node

    # @return [Obsidian::Node, nil] the previous node in the sequence
    attr_accessor :previous_node

    def initialize(data)
      self.data = data
    end
  end
end