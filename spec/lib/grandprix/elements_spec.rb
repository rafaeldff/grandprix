require 'spec_helper'

describe Grandprix::Elements do
  def make(elements_array)
    Grandprix::Elements.build elements_array
  end

  it { (make(["a","b"]) + make(["c","d"])).should == make(["a","b","c","d"]) }

  it { (make(["a","b","c","d"]).except ["c","d"]).should == make(["a","b"]) }


  it "should store extra information for each name" do
    elements = make ["first=0.1", "second=0.2"]
    elements.underlying.should == [["first", "0.1"], ["second", "0.2"]]
  end

  describe :reorder do
    it "should reorder the elements according to the given names sequence" do
      (make(["a","c"]).reorder ["d","c","b","a"]).should == make(["c","a"]) 
    end
   
    it "should remove elements whose names are absent from the ordering" do
      elements = make ["prost"]
      order = ["prost_externo", "prost", "assets", "schumi"]

      result = elements.reorder order
      result.should == elements
    end
  end

  describe :alongside do
    it "should store the extra names" do
      (make(["a","c"]).alongside [["a", ["aa"]], ["c", ["cc"]]]).should == make(["a", "c", "aa", "cc"]) 
    end

    it "should copy extra data from the stored names to the names defined alongside" do
      elements = make ["first=0.1", "second=0.2", "third"]
      res = elements.alongside [["first", ["one"]], ["second", ["two"]], ["third", ["three"]]]
      res.strings.should =~ ["first=0.1", "second=0.2", "third", "one=0.1", "two=0.2", "three"]
    end

    it "REGRESSION: it should not add unrelated names" do
      elements = make ["prost=1.2.3"]
      alongside = {"schumi"=>["assets"], "prost"=>["prost_externo"]}

      res = elements.alongside alongside
      res.should == make(["prost=1.2.3","prost_externo=1.2.3"])
    end
  end

  describe :annotate do
    it "should add extra string information to the appropriate names" do
      elements = make ["first=1", "second=2", "third", "fourth=4", "fifth"]
      res = elements.annotate "first" => "10", "second" => "20", "third" => "30"
      res.strings.should == ["first=1=10", "second=2=20", "third==30", "fourth=4", "fifth"]
    end
    
    it "should add extra object information to the appropriate names" do
      elements = make ["first=1"]
      res = elements.annotate "first" => {:a => "some string", "b" => ["other"]}
      res.strings.size.should == 1

      line = res.strings.first 
      line.should match %r|first=1={.*}|
      JSON.parse(res.strings.first.split(/=/).last).should  include({"a" => "some string", "b" => ["other"]})
    end

    it "should format properly when the element has no prior extra information but is annotated" do
      elements = make ["backend"]
      res = elements.annotate "backend" => "this is the backend"
      res.strings.should == ['backend==this is the backend']
    end
  end
end
