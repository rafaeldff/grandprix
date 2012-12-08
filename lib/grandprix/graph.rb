class Grandprix::Graph
  class Sort
    def initialize(graph)
      @graph = graph
      @preds = {}
      @succ  = {}
    end
    
    def solve
      analize

      #sort_graph
      res = []
      (0..10).each do |i|
        ranks = @preds.select{|k,v| v == i }.keys
        res = res + ranks
      end
      res
    end

    def analize
      init_tables

      @graph.each do |j, k|
        @preds[k] += 1
        @succ[j].push k
      end

      puts "preds: #{@preds.inspect}"
      puts "succ: #{@succ.inspect}"
    end

    def init_tables
      @graph.each do |pair|
        j, k = pair
        p j, k
        @preds[j] = 0 
        @preds[k] = 0
        @succ[j] = []
        @succ[k] = []
      end
    end

    def sort_graph
      def loop(out)
        return if out.empty?

      end

      initial_out = indexes(@preds) {|x| x == 0 }
      loop initial_out
    end

    private
    def indexes(hash)
      res = []
      hash.each do |x, i|
        res.push i if yield(x)  
      end
      res
    end
  end

  def sort(graph)
   Sort.new(graph).solve
  end
end
