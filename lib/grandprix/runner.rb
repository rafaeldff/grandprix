class Grandprix::Runner
  def run!(topology, elements)
    graph = Grandprix::Graph.new
    Grandprix::Planner.new(graph).plan(topology, elements)
  end
end
