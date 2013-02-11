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
      selected = @counts.select {|vertex,count| count == 0 }
      hash_selected = Hash[selected]
      hash_selected.keys      
    end

    def zeroes_among(vertices)
      vertices.select do |v|
        @counts[v] == 0
      end
    end

    def size
      @counts.size
    end

    def to_s
      ks = @counts.keys.map{|k| k.to_s.rjust 2}.join(" ")
      vs = @counts.values.map{|v| v.to_s.rjust 2}.join(" ")
      "Predecessors:\n#{ks}\n#{vs}\n"
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

    def to_s
      ks = @successors.keys.map{|k| k.to_s.rjust 6}.join(" ")
      vs = @successors.values.map{|v| v.inspect.rjust 6}.join(" ")
      "Successors  :\n#{ks}\n#{vs}\n"
    end
  end

  class CycleDetected < Exception
  end
end
