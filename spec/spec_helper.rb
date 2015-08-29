$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'ajimi'

def make_entry(line)
  Ajimi::Server::Entry.parse(line)
end
