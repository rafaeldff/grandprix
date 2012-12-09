require 'spec_helper'

# This is an integration test
describe Grandprix::Runner do
  it "should understand dependencies" do
    topology = {
      "frontend" => {
        "after" => ["backend"]
      },
      "backend" => {
        "after" => ["db", "mq"]
      },
      "client" => {
        "after" => ["frontend"]
      }
    }

    elements = ["frontend", "db", "client"]
    
    subject.run!(topology, elements).should == ["db", "frontend", "client"]
  end
  
end
