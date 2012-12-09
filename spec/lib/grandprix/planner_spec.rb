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

  it "should include elements that must always be deployed together" do
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

    expected_deps = [
      ["backend", "frontend"], 
      ["backend", "assets"], 
      ["backend", "images"], 
      ["external_backend", "frontend"], 
      ["external_backend", "assets"], 
      ["external_backend", "images"], 
    ]

    graph.should_receive(:sort) do |arg|
      arg.should =~ expected_deps
      ["backend", "external_backend", "assets", "images", "frontend"]
    end

    result = subject.plan(topology, elements)

    result.should =~ ["assets", "images", "frontend", "backend", "external_backend"]
    result.should beOrderedHaving("assets", "images").before("frontend")
    result.should beOrderedHaving("backend", "external_backend").before("frontend")
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
