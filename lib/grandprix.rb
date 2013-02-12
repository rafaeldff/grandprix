module Grandprix
  # Your code goes here...
end

require 'json'
require 'active_support'
require 'grandprix/elements'
require 'grandprix/graph'
require 'grandprix/planner'
require 'grandprix/runner'

if RUBY_VERSION =~ /^1\.8/
  class Array
    def flat_map
      self.reduce([]) {|so_far, current| so_far + yield(current)}
    end

    def to_ordered_hash
      ActiveSupport::OrderedHash[self]
    end
  end

  class Hash
    def flat_map
      self.reduce([]) do |so_far, current|
        key = current[0]
        value = current[1]
        so_far + yield(key, value)
      end
    end
  end
end


if RUBY_VERSION =~ /^((1\.9)|2)/
  class Array
    def to_ordered_hash
      Hash[self]
    end
  end
end
