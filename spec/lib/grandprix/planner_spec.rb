require 'spec_helper'

describe Grandprix::Planner do
  let (:graph) { mock("graph") }
  subject { described_class.new graph }

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
    
    graph.should_receive(:sort).with([
      ["backend", "frontend"], 
      ["db", "backend"], 
      ["mq", "backend"], 
      ["frontend", "client"], 
    ]).and_return(["mq", "db", "backend", "frontend", "client"])

    subject.plan(topology, elements).should == ["db", "frontend", "client"]
  end

  xit "should include elements that must always be deployed together" do
    topology = {
      "frontend" => {
        "after" => ["backend"],
        "alongside" => ["assets", "images"]
      },
      "backend" => {
        "alongside" => ["external_backend"]
      }
    }

    elements = ["frontend", "backend"]
    
    graph.should_receive(:sort).with([
      ["backend", "frontend"], 
      ["backend", "assets"], 
      ["backend", "images"], 
      ["external_backend", "frontend"], 
      ["external_backend", "assets"], 
      ["external_backend", "images"], 
    ]).and_return(["backend", "external_backend", "assets", "images", "frontend"])

    subject.plan(topology, elements).should == ["db", "frontend", "client"]
  end

  context " - input handling - " do
    it "should consider elements that are mentioned but not fully specified" do
      topology = {
        "frontend" => {
          "after" => ["backend"]
        },
        "backend" => {
          "after" => ["db", "mq"]
        },
      }

      elements = ["frontend", "db", "client"]

      graph.should_receive(:sort).with([
        ["backend", "frontend"], 
        ["db", "backend"], 
        ["mq", "backend"], 
      ]).and_return(["mq", "db", "backend", "frontend"])

      subject.plan(topology, elements).should == ["client","db", "frontend"]
    end

  end


  #topology = {
  #"frontend" => {
  #"after" => ["backend", "assets"],
  #"alongside" => ["assets", "images"]
  #},
  #"backend" => {
  #"alongside" => ["external_backend"]
  #}
  #}
end
