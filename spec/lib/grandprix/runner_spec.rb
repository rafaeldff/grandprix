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
    
    subject.run!(topology, elements).names.should == ["db", "frontend", "client"]
  end

  it "a complex case" do
    topology = {
      "frontend" => {
      "after" => ["backend", "assets"],    # frontend depends on assets in addxition to
      "alongside" => ["assets", "images"]  # having it declared alongside
    },
      "backend" => {
      "alongside" => ["external_backend"]
    },
      "images" => {
      "after" => ["client"] #images that is an alongside dep of frontend depends on client
    }
    }

    elements = ["frontend", "client", "backend", "extra"] #extra is not mentioned on the topology
    result = subject.run!(topology, elements)

    result.names.should =~ ["client", "backend", "external_backend", "frontend", "assets", "images", "extra"]
    result.should beOrderedHaving("backend", "assets").before("frontend")
    result.should beOrderedHaving("backend", "assets").before("frontend", "assets", "images")
    result.should beOrderedHaving("client").before("images")
  end

  it "REGRESSION" do
    topology = {
      "schumi" =>  {
        "after" =>  ["prost", "assets"],
        "alongside" =>  ["assets"],
        "annotation" =>  "r7-schumi"
      },

      "prost" =>  {
        "alongside" =>  ["prost_externo"],
        "annotation" =>  "r7-prost"
      },

      "assets" =>  {
        "annotation" =>  "r7-cms-assets"
      }
    }

    elements = ["prost=1.2.3"]
    result = subject.run!(topology, elements)

    expected = [
      "prost_externo=1.2.3",
      "prost=1.2.3=r7-prost"
    ]

    result.strings.should =~ expected
  end

end
