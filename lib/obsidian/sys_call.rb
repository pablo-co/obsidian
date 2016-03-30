module Obsidian
  # An Obsidian::SysCall is the representation of a system call
  # done by a {Task}. It is an empty entity, it only stores data.
  # @see Obsidian::Task
  class SysCall
    # @return [Symbol] the type of system call made. The
    #   interpretation of this value depends of the client
    #   using it.
    attr_accessor :type

    # @return [Object] the arguments created with this system call
    attr_accessor :data

    def initialize(args = {})
      self.type = args.fetch(:type)
      self.data = args.fetch(:data)
    end
  end
end