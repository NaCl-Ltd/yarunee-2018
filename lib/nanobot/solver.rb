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
      @logger.level = Logger::INFO
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

    def high_harmonics_needed?
      @model.has_eaves?
    end

    # 複数のbotに同時に命令を与える
    # cmds_list: {id => [cmds...]}
    # 指定がないbotや、時間が余った場合はWaitで待つ
    def parallel(cmds_list)
      #cmds_list.each{|id, l| puts "bot#{id}: #{l.inspect}"}

      max_cmds_len = cmds_list.values.map(&:length).max
      padded_cmds_list = @bots.keys.map{|id|
        cmds = cmds_list[id] || []
        waits = [Wait.instance] * (max_cmds_len - cmds.length)
        [id, waits + cmds]
      }.to_h
      sorted_cmds_list = padded_cmds_list.sort_by{|id, l| id}.map(&:last)
      @trace.add_commands(*sorted_cmds_list.transpose.flatten(1))

      # botが増えた場合の処理
      cmds_list.each do |id, cmds|
        cmds.grep(Fission).each do |cmd|
          @bots[cmd.new_bot_id] = Bot.new(cmd.new_bot_id, *cmd.new_bot_pos)
        end
      end
      # botが減った場合の処理(現状では1組のみ対応)
      primary_id,   _ = cmds_list.find{|id, cmds| cmds.any?{|c| FusionP === c}}
      secondary_id, _ = cmds_list.find{|id, cmds| cmds.any?{|c| FusionS === c}}
      raise "FusionPとFusionSがセットになっていない" if !!primary_id ^ !!secondary_id
      if primary_id
        @bots.delete(secondary_id)
      end
    end

    # 複数のbotに同時に命令を与える
    # 命令はblockで与える(botを受け取り、cmdsを返すこと)
    def cmd_all(&block)
      cmds_list = @bots.map{|id, bot|
        [id, block.call(bot)]
      }.to_h
      parallel(cmds_list)
    end

    # add_commandsのショートカット
    def cmd(*cmds)
      @logger.debug(cmds)
      @trace.add_commands(*cmds)
    end
  end
end
