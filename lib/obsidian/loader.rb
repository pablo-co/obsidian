module Obsidian
# An entity which loads or creates all the data
# needed to create a {PCB}.
# @see FileLoader for reference implementation
# @abstract - subclass and implement {#load}.
  class Loader
    # Loads the data of a new task
    # @return [Hash] the attributes for the PCB
    # @raise [StandardError] if {#load} is not implemented
    def load(data = {})
      raise StandardError.new('Loader#load is not implemented')
    end
  end
end