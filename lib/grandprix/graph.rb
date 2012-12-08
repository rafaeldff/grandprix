class Grandprix::Graph
  class Sort
    def initialize(graph)
      @graph = graph
      @preds_count = {}
      @successors  = {}
    end
    
    def solve
      analize

      sort_graph
    end

    def analize
      init_tables

      @graph.each do |j, k|
        @preds_count[k] += 1
        @successors[j].push k
      end
    end

    def init_tables
      @graph.each do |pair|
        j, k = pair
        @preds_count[j] = 0 
        @preds_count[k] = 0
        @successors[j] = []
        @successors[k] = []
      end
    end

    def sort_graph
      def loop(outs, left, res)
        return res if outs.empty?
        out, *new_outs = outs

        successors = @successors[out]
        successors.each do |suc|
          @preds_count[suc] -= 1
          new_outs.push suc if @preds_count[suc] == 0
        end
        loop new_outs, left-1, res.push(out)
      end

      initial_out = with_pred_count 0
      loop initial_out, num_vertices, []
    end

    private
    def with_pred_count n
      @preds_count.select {|k,v| v == n }.keys
    end

    def num_vertices
      @preds_count.size
    end
  end

  def sort(graph)
   Sort.new(graph).solve
  end
end
