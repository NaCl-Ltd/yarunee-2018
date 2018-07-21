require 'nanobot/model'
require 'nanobot/command'
require 'nanobot/trace'

class Nanobot
  # モデルを受け取って命令列を出力するクラス
  class Solver
    def initialize(model)
      @model = model
      @trace = Trace.new
    end

    # Traceを返す
    def solve
      raise "override me"
    end
    
    private

    # add_commandsのショートカット
    def cmd(*cmds)
      @trace.add_commands(*cmds)
    end
  end
end
