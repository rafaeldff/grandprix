class Grandprix::Planner
  def initialize(graph)
    @graph = graph
  end

  def plan(topology, elements)
    nested_dependencies = project(topology, "after")
    alongside = project(topology, "alongside")

    dependencies = flatten_edges nested_dependencies

    full_dependencies = dependencies.flat_map do |from, to|
      extended_from = alongside[from] + [from]
      extended_to   = alongside[  to] + [to  ]
      new_deps = extended_from.product extended_to

      compact_pairs(new_deps)
    end

    before_relation = invert full_dependencies

    in_order = @graph.sort before_relation

    full_elements = elements + alongside.values.flatten.uniq
    independent_elements = elements - in_order
    elements_in_order = in_order & full_elements

    independent_elements + elements_in_order
  end

  private
  def project(hash, key)
    projected = Hash[ compact_pairs hash.map{|element, config| [element, config[key]]} ]
    projected.default = []
    projected
  end

  def invert(edges)
    edges.map {|k, v| [v, k]}
  end

  def compact_pairs(pairs)
    pairs.reject do |pair|
      pair.nil? || pair[0].nil? || pair[1].nil?
    end
  end

  def flatten_edges(vertex_to_successors)
    vertex_to_successors.flat_map {|vertex_j, successors| successors.map {|vertex_k| [vertex_j, vertex_k] } }
  end

end
