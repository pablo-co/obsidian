require_relative 'node'

module Obsidian
  # An Obsidian::List is a double linked list that stores a variable amount of
  # of data using {Obsidian::Node}.
  # @see Obsidian::Node
  class List
    # @return [Obsidian::Node, nil] the first node of the list, nil if it's empty
    attr_accessor :head

    # @return [Integer] the amount of elements in the list
    attr_reader :size

    def initialize
      self.size = 0
    end

    # Returns the last element of the list
    # @return [Node]
    def tail
      node_at(size - 1)
    end

    # Adds a new data object at the end of the list
    # @param value [Object] the data that should be pushed in the list
    # @return [Object] the data that was pushed
    def push(value)
      push_at(size, value)
    end

    # Adds a new data object at a given place in the list
    # @param index [Integer] the place in the list where the data should be placed
    # @param value [Object] the data that should be pushed in the list
    # @return [Object] the data that was pushed
    def push_at(index, value)
      new_node = create_node(value)
      node = node_at(index - 1)
      push_after(node, new_node) if node
      self.head = new_node if index == 0
      self.size += 1
      new_node.data
    end

    # Removes and returns the data entity at the start of the list
    # @return [Object] the data at the start of the list
    def pop
      node = remove_node(head)
      return nil unless node
      self.size -= 1
      node.data
    end

    # Return whether the list is empty.
    # @return [true|false] list is empty?
    def empty?
      head.nil?
    end

    # Iterate over each of the elements in the list using a block.
    # If the block returns true, the element is removed from the list.
    # If it returns false, the element remains untouched
    # @example Delete all nodes whose data has the attribute type with value 'first'
    #   list.delete_if { |element| element.type == 'first' }
    # @return [nil]
    def delete_if
      return unless head
      node = head
      begin
        next_node = node.next_node
        if yield node.data
          remove_node(node)
          self.size -= 1
        end
        node = next_node
      end while node != nil
    end

    def to_s
      result = ''
      for_each { |data| result += data.to_s }
      result
    end

    # Iterate over each of the elements in the list using a block.
    # @example Print to the standard output all elements in the list
    #   list.for_each { |element| puts element }
    # @return [nil]
    def for_each
      return unless head
      node = head
      begin
        yield node.data
        node = node.next_node
      end while node != nil
    end

    protected

    # @see #size
    attr_writer :size

    private


    # Removes the given node from the list
    # @param node [Node] the node that should be removed
    # @return [Node, nil] the node that was removed, nil if there was no node removed
    def remove_node(node)
      return nil unless node
      previous_node = node.previous_node
      next_node = node.next_node
      previous_node.next_node = next_node if previous_node
      next_node.previous_node = previous_node if next_node
      self.head = node.next_node if node == head
      node
    end

    # Adds a node in the list just before another given node.
    # @param node [Node] the reference node
    # @param new_node [Node] the new node that should be inserted before the reference node
    # @return [nil]
    def push_before(node, new_node)
      new_node.previous_node = node.previous_node
      new_node.next_node = node
      node.previous_node.next_node = new_node
      node.previous_node = new_node
    end

    # Adds a node in the list just after another given node.
    # @param node [Node] the reference node
    # @param new_node [Node] the new node that should be inserted after the reference node
    # @return [nil]
    def push_after(node, new_node)
      new_node.previous_node = node
      new_node.next_node = node.next_node
      node.next_node = new_node
    end

    # Get the node that is found at a given index in the list
    # @param index [Integer] the index of the node that should be returned
    # @return [Node, nil] the node that that index or nil if it doesn't exist
    def node_at(index)
      node = head
      index.times { node = node.next_node }
      node
    end

    # Create a new node to wrap around some given data
    # @param value [Object] the data the new node should wrap
    # @return [Node] the node that was created
    def create_node(value)
      Node.new(value)
    end
  end
end