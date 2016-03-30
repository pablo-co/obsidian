(%w{obsidian/*.rb}).each do |directory|
  Dir[directory].each { |file| require_relative file }
end

module Obsidian
end
