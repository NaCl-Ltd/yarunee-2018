require 'logger'
require 'nanobot/model'
require 'nanobot/command'
require 'nanobot/trace'
require 'nanobot/bot'

class Nanobot
  # モデルを受け取って命令列を出力するクラス
  class Solver
    include Command  # いちいちCommand::って書くのが面倒なので

    def initialize(model)
      @model = model
      @trace = Trace.new
      @bots = {1 => Bot.new(1)}
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

    # 複数のbotに同時に命令を与える
    def parallel(cmds_list)
      if cmds_list.size != @bots.size
        raise ArgumentError, "ボット数=#{@bots.size} 命令列数=#{cmds_list.size}"
      end

      sorted_bots = @bots.sort_by{|k, v| k}.map(&:last)
      bots_cmds = sorted_bots.zip(cmds_list)
      @logger.debug("複数botに命令を発行します\n" +
                    bots_cmds.map{|b, l| "bot#{b.id}: #{l.inspect}"}.join("\n"))

      max_cmds_len = cmds_list.map(&:length).max
      padded_cmds_list = cmds_list.map{|l|
        l + [Wait.new] * (max_cmds_len - l.length)
      }
      @trace.add_commands(*padded_cmds_list.transpose.flatten(1))
    end

    # add_commandsのショートカット
    def cmd(*cmds)
      @logger.debug(cmds)
      @trace.add_commands(*cmds)
    end
  end
end
