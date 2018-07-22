require 'logger'
require 'nanobot/model'
require 'nanobot/command'
require 'nanobot/trace'

class Nanobot
  # モデルを受け取って命令列を出力するクラス
  class Solver
    include Command  # いちいちCommand::って書くのが面倒なので

    def initialize(model)
      @model = model
      @trace = Trace.new
      @logger = Logger.new($stdout)
      @logger.level = Logger::DEBUG
    end
    attr_writer :logger

    # Traceを返す
    def solve
      raise "override me"
    end

    # 盤面を複数に分割する
    def split_areas()

      return 
    end
    
    private

    # add_commandsのショートカット
    def cmd(*cmds)
      @logger.debug(cmds)
      @trace.add_commands(*cmds)
    end
  end
end
