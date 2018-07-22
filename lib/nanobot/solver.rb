require 'logger'
require 'nanobot/model'
require 'nanobot/command'
require 'nanobot/trace'
require 'nanobot/bot'

class Nanobot
  # モデルを受け取って命令列を出力するクラス
  class Solver
    include Command  # いちいちCommand::って書くのが面倒なので

    HEIGHT = 4
    WIDTH = 5

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
      raise "盤面が5x5より小さいので分割できません" if @model.resolution < 5
      heights, widths = [
        [HEIGHT, @model.resolution.divmod(HEIGHT)],
        [WIDTH, @model.resolution.divmod(WIDTH)],
      ].map do |size, divmod|
        size.times.map { |i| i == size-1 ? i * divmod[0] + divmod[1] : i * divmod[0] }
      end
      heights.flat_map.with_index do |height, hi|
        widths.map.with_index do |width, wi|
          [[width, height],
           [widths[wi+1] ? widths[wi+1]-1 : @model.resolution-1,
            heights[hi+1] ? heights[hi+1]-1 : @model.resolution-1]]
        end
      end
    end

    private

    # 複数のbotに同時に命令を与える
    # cmds_list: {id => [cmds...]}
    def parallel(cmds_list)
      if cmds_list.size != @bots.size
        raise ArgumentError, "ボット数=#{@bots.size} 命令列数=#{cmds_list.size}"
      end

      @logger.debug("複数botに命令を発行します\n" +
                    cmds_list.map{|id, l| "bot#{id}: #{l.inspect}"}.join("\n"))

      max_cmds_len = cmds_list.values.map(&:length).max
      padded_cmds_list = cmds_list.map{|id, l|
        waits = [Wait.new] * (max_cmds_len - l.length)
        [id, l + waits]
      }.to_h
      sorted_cmds_list = padded_cmds_list.sort_by{|id, l| id}.map(&:last)
      @trace.add_commands(*sorted_cmds_list.transpose.flatten(1))
    end

    # add_commandsのショートカット
    def cmd(*cmds)
      @logger.debug(cmds)
      @trace.add_commands(*cmds)
    end
  end
end
