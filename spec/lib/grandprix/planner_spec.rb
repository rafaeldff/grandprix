require 'spec_helper'

describe Grandprix::Planner do
  let (:graph) { mock("graph") }
  subject { described_class.new graph }

  xit "should understand dependencies" do
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

    xit "should allow for alongside dependencies to declare their own dependencies" do
      topology = {
        "frontend" => {
          "after" => ["backend", "assets"],    # frontend depends on assets in addxition to
          "alongside" => ["assets", "images"]  # having xit declared alongside
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
    xit "should consider elements that are mentioned but not fully specified" do
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

  context " - output - " do
    it "should annotate the elements with provided metadata, if given" do
      topology = {
        "frontend" => {
          "after" => ["backend"],
          "annotation" => "this is the frontend"
        },
        "backend" => {
          "after" => ["db"]
        },
        "db" => {
          "annotation" => {"type" => "document-oriented"}
        }
      }

      elements = ["frontend=1.0.0", "backend=2.0.0", "db"]

      graph.should_receive(:sort).with([
        ["backend", "frontend"], 
        ["db", "backend"], 
      ]).and_return(["db", "backend", "frontend"])

      subject.plan(topology, elements).strings.should == ['db=={"type":"document-oriented"}', 'backend=2.0.0', 'frontend=1.0.0="this is the frontend"']
    end

  end


end
