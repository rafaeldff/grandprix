require 'spec_helper'

describe "Extension" do
  describe "Array.flat_map" do
    it { [1,2,3].flat_map{|x| [x,x]}.should == [1,1,2,2,3,3]}
    it { [1,2,3,4].flat_map{|x| x % 2 == 0 ? [x] : [] }.should == [2,4]}
  end

  describe "Hash.flat_map" do
    it do
      h = {:a => 10, :b => 20}
      res = h.flat_map do |k, v|
        [k, v, v]
      end
      res.should == [:a, 10, 10, :b, 20, 20]
    end

    it do
      h = {:a => 1, :b => 2, :b => 3, :c => 4}
      res = h.flat_map do |k, v|
        v % 2 == 1 ? [k] : []
      end
      res.should == [:a, :b]
    end
  end
end
