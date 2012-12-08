require 'spec_helper'

describe Grandprix::Graph do
  describe :topological_sort do
    it "should sort a linked list" do
      subject.sort([[:a, :b],[:b, :c]]).should == [:a, :b, :c] 
    end
    
    it "should sort a small graph" do
      
    end
  end  
end
