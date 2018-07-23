require 'nanobot/solver3'
require 'nanobot/solver4'

class Nanobot
  # reconstructionのソルバ
  class Solver5 < Solver
    def initialize(model_src, model_tgt)
      @solver3 = Solver3.new(model_tgt)
      @solver4 = Solver4.new(model_src)
    end

    def solve
      trace = @solver4.solve(recon_mode: true)
      trace2 = @solver3.solve(recon_mode: true)
      trace.join!(trace2)
      return trace
    end
  end
end
