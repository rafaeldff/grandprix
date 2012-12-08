require 'spec_helper'


describe Grandprix::Graph do
  describe :topological_sort do
    it "should sort a linked list" do
      edges = [[:a, :b],[:b, :c]]
      subject.sort(edges).should be_an_ordering_of(edges)
      subject.sort(edges).should == [:a, :b, :c] 
    end
    
    it "should sort a small graph" do
      #         d
      #        ^^
      #       /  \
      # a -> b -> c <- e
      edges = [
        [:a, :b],
        [:b, :c],
        [:b, :d],
        [:c, :d],
        [:e, :c],
      ]
      subject.sort(edges).should  be_an_ordering_of(edges)
    end

    it "should sort a larger graph" do
      # 
      #               4 -> 6 <- 8  <-  2
      #               ^         ^      ^
      #               |         |      |
      # 1  ->  3  ->  7   --->  5  <-  9
      edges = [
        [9, 2], [4, 6],
        [3, 7], [1, 3],
        [7, 5], [7, 4],
        [5, 8], [9, 5],
        [8, 6], [2, 8],
      ]
      res = subject.sort(edges)

      #new_edges = edges.push [10, 20]
      res.should  be_an_ordering_of(edges)
    end
  end  
end
