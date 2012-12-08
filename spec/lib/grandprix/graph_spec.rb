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
      subject.sort(edges).should  be_an_ordering_of(edges)
    end

    context "invalid input" do
      it "should do nothing on empty imput" do
        subject.sort([]).should == []
      end
      
      it "should raise an exception when a cycle is found" do
        #
        #  A -> B
        #  ^    |
        #  |    v
        #  D <- C
        #
        expect { subject.sort([[:a, :b], [:b, :c], [:c, :d], [:d, :a]]) }.to raise_error
      end

      it "should raise an exception when a cycle is found inside a graph" do
        #
        #        D <- E <- F -> H <-
        #        |         ^         \
        #        |         |          J
        #        v         \         /
        #  A ->  B -> C -> G -> I <-
        #
        expect { subject.sort([
          [:a, :b],
          [:b, :c],
          [:c, :g],
          [:g, :i],
          [:e, :d],
          [:f, :e],
          [:f, :h],
          [:d, :b],
          [:g, :f],
          [:j, :h],
          [:j, :i],
        ]) }.to raise_error
      end
    end

  end  
end
