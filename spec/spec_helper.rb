$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'ajimi'
require 'diff/lcs'

def make_entry(line)
  Ajimi::Server::Entry.parse(line)
end

def make_change(action, position, element)
  ::Diff::LCS::Change.new(action, position, element)
end
