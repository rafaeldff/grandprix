module Grandprix
  # Your code goes here...
end

require 'json'
require 'grandprix/elements'
require 'grandprix/graph'
require 'grandprix/planner'
require 'grandprix/runner'

if RUBY_VERSION =~ /^1\.8/
  class Array
    def flat_map
      self.reduce([]) {|so_far, current| so_far + yield(current)}
    end
  end

  class Hash
    def flat_map
      self.reduce([]) do |so_far, current|
        key = current[0]
        value = current[1]
        yield(key, value) + so_far
      end
    end
  end
end
