module Obsidian
  module Memory
    # Representation of a range of addresses in memory or space. It keeps
    # track of the base address and total size.
    Space = Struct.new(:address, :size)
  end
end
