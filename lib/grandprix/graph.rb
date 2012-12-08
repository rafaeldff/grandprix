class Grandprix::Graph
  class PredecessorCount
    def initialize(edges)
      @preds_count = {}
      edges.each do |pair|
        j, k = pair
        @preds_count[j] = 0 
        @preds_count[k] = 0
      end
      
      edges.each do |j, k|
        @preds_count[k] += 1
      end
    end

    def decrement_all(vertices)
      vertices.each do |suc|
        @preds_count[suc] -= 1
      end
    end

    def zeroes
      @preds_count.select {|vertex,count| count == 0 }.keys      
    end

    def zeroes_among(vertices)
      vertices.select do |v|
        @preds_count[v] == 0
      end
    end

    def size
      @preds_count.size
    end
  end

  class Sort
    def initialize(graph)
      @graph = graph
      @preds_count = PredecessorCount.new graph
      @successors  = {}
    end
    
    def solve
      analize

      sort_graph
    end

    def analize
      init_tables

      @graph.each do |j, k|
        @successors[j].push k
      end
    end

    def init_tables
      @graph.each do |pair|
        j, k = pair
        @successors[j] = []
        @successors[k] = []
      end
    end

    def sort_graph
      def visit(queue, left, ordered_vertices)
        return ordered_vertices if queue.empty?
        current, *rest = queue

        successors = @successors[current]
        @preds_count.decrement_all successors

        new_queue = rest + @preds_count.zeroes_among(successors)
        visit new_queue, left-1, ordered_vertices.push(current)
      end

      visit initial_queue, num_vertices, []
    end

    private
    def initial_queue
      @preds_count.zeroes
    end
    def num_vertices
      @preds_count.size
    end
  end

  def sort(graph)
   Sort.new(graph).solve
  end
end
