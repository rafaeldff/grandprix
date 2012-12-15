#! /usr/bin/env ruby

require 'grandprix'

topology = {
  "frontend" => {
    "after" => ["backend"]
  },
  "backend" => {
    "after" => ["db", "mq"],
    "annotation" => {
      "deploy-type" => "rolling",
    }
  },
  "client" => {
    "after" => ["frontend"],
    "annotation" => {
      "deploy-type" => "restart",
    }
  }
}

elements = ["frontend=v1.0.0", "db=v2.0.1", "client=v5.43.4"]

output_elements = Grandprix::Runner.new.run! topology, elements

puts "Just the names are:\n#{output_elements.names.inspect}"

puts "The full elements are:\n#{output_elements.strings.inspect}"
