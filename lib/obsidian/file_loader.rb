require 'yaml'
require_relative 'loader'


module Obsidian
  # A {Loader} implementation for loading PCBs from
  # YAML files. Keys in the file are the {PCB} attributes
  # while the values are their corresponding value.
  class FileLoader < Loader
    # (see Loader#load)
    def load(data = {})
      file = data.fetch(:file)
      YAML.load_file(file)
    end
  end
end