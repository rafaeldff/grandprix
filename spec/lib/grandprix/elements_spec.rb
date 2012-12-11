require 'spec_helper'

describe Grandprix::Elements do
  def make(elements_array)
    Grandprix::Elements.build elements_array
  end

  it { (make([:a,:b]) + make([:c,:d])).should == make([:a,:b,:c,:d]) }

  it { (make([:a,:b,:c,:d]).except [:c,:d]).should == make([:a,:b]) }

  it { (make([:a,:c]).reorder [:d,:c,:b,:a]).should == make([:c,:a]) }

  it "should store extra information for each name" do
    elements = make ["first=0.1", "second=0.2"]
    elements.underlying.should == [["first", "0.1"], ["second", "0.2"]]
  end

  describe :alongside do
    it "should store the extra names" do
      (make([:a,:c]).alongside a: [:aa], c: [:cc]).should == make([:a, :c, :aa, :cc]) 
    end

    it "should copy extra data from the stored names to the names defined alongside" do
      elements = make ["first=0.1", "second=0.2"]
      res = elements.alongside "first" => ["one"], "second" => ["two"]
      res.underlying.should == [["first", "0.1"], ["second", "0.2"], ["one", "0.1"], ["two", "0.2"]]
    end
  end
end
