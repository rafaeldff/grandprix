class Grandprix::Graph
  def sort(graph)
   Sort.new(graph).solve
  end

  class Sort
    def initialize(graph)
      @graph = graph
      @preds_count = PredecessorCount.new graph
      @successors  = SuccessorTable.new graph
    end
    
    def solve
      sort_graph
    end

    def sort_graph
      def visit(queue, ordered_vertices)
        return ordered_vertices if queue.empty?
        current, *rest = queue

        successors = @successors.of(current)
        @preds_count.decrement_all successors

        new_queue = rest + @preds_count.zeroes_among(successors)
        visit new_queue, ordered_vertices.push(current)
      end

      check_for_cycles visit(initial_queue, [])
    end

    private
    def initial_queue
      @preds_count.zeroes
    end

    def num_vertices
      @preds_count.size
    end

    def check_for_cycles(seq)
      raise CycleDetected if seq.size < num_vertices
      seq
    end
  end

  class PredecessorCount
    def initialize(edges)
      @counts = {}
      edges.each do |j, k|
        @counts[j] ||= 0 
        @counts[k] ||= 0 

        @counts[k] += 1
      end
    end

    def decrement_all(vertices)
      vertices.each do |suc|
        @counts[suc] -= 1
      end
    end

    def zeroes
      @counts.select {|vertex,count| count == 0 }.keys      
    end

    def zeroes_among(vertices)
      vertices.select do |v|
        @counts[v] == 0
      end
    end

    def size
      @counts.size
    end
  end

  class SuccessorTable
    def initialize(edges)
      @successors = {}
      edges.each do |j, k|
        @successors[j] ||= []
        @successors[k] ||= []

        @successors[j].push k
      end
    end

    def of(origin)
      @successors[origin]
    end
  end

  class CycleDetected < Exception
  end
end
