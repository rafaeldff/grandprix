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

    subject.plan(topology, elements).names.should == ["db", "frontend", "client"]
  end

  context " - alongside - " do
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
        ["external_backend", "backend", "frontend", "assets", "images"]
      end

      result = subject.plan(topology, elements)

      result.names.should =~ ["assets", "images", "frontend", "backend", "external_backend"]
      result.should beOrderedHaving("backend", "external_backend").before("frontend","assets", "images")
    end

    it "should allow for alongside dependencies to declare their own dependencies" do
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

      elements = ["frontend", "client", "backend"]
      expected_deps = [
        ["assets", "frontend"], 
        ["assets", "images"], 
        ["client", "images"], 
        ["backend", "frontend"], 
        ["backend", "assets"], 
        ["backend", "images"], 
        ["external_backend", "frontend"], 
        ["external_backend", "assets"], 
        ["external_backend", "images"], 
      ]

      graph.should_receive(:sort) do |arg|
        arg.should =~ expected_deps
        ["client", "backend", "external_backend", "assets", "images", "frontend"]
      end

      result = subject.plan(topology, elements)

      result.names.should =~ ["client", "backend", "external_backend", "frontend", "assets", "images"]
      result.should beOrderedHaving("backend", "assets").before("frontend")
      result.should beOrderedHaving("backend", "assets").before("frontend", "assets", "images")
      result.should beOrderedHaving("client").before("images")
    end
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

      subject.plan(topology, elements).names.should == ["client","db", "frontend"]
    end

  end


end
