class Grandprix::Planner
  def initialize(graph)
    @graph = graph
  end

  def plan(topology, elements)
    nested_dependencies = topology.map{|topology_element, config| [topology_element, config["after"]]}.compact
    dependencies = nested_dependencies.flat_map {|el, deps| deps.map {|dep| [el, dep] } }
    before_relation = invert dependencies

    in_order = @graph.sort before_relation
    independent_elements = elements - in_order
    elements_in_order = in_order & elements

    independent_elements + elements_in_order
  end

  private
  def invert(edges)
    edges.map {|k, v| [v, k]}
  end

end
