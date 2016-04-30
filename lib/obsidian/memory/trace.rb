module Obsidian
  module Memory
    # A trace is a representation of a given set of tasks, memory size and
    # state in a theoretical computer and OS.
    Trace = Struct.new(
      :mem_size,
      :mem_spaces,
      :tasks
    )
  end
end
