require 'nanobot/solver'

class Nanobot
  # 分裂を行うソルバ
  #
  # 分裂処理の都合で、bot1が最後のエリア(@area[19])を担当する
  class Solver3 < Solver
    def initialize(*args)
      super
      @r = @model.resolution
      if @model.resolution < 5
        raise "このマップは小さすぎるのでSolver2で十分です"
      end
      if @model.max_y == @r-1
        raise "一番上までmatterが詰まっているマップは解けません(;_;)"
      end
      if @model.min_x == 0 || @model.min_z == 0
        raise "原点の上にmatterがあるマップは解けません(;_;)"
      end
      @x, @y, @z = 0, 0, 0
      @areas = split_areas
      @n_areas = @areas.size
    end

    def solve
      cmd(Flip.new) if high_harmonics_needed?
      do_fissions
      for y in 0..@model.max_y
        print_layer(y)
      end
      do_fusions
      @logger.debug("建築作業が完了しました")
      cmd(Flip.new) if high_harmonics_needed?
      cmd(Halt.new)
      return @trace
    end

    private

    def high_harmonics_needed?
      true
      # TODO: 下がVoidであるmatterが存在するときだけ真を返すようにする
    end

    # 分裂を行い、各botを初期位置に配置する
    def do_fissions
      for i in 2..@n_areas
        do_fission(i)
      end
    end

    # i番目のbotの生成処理を行う
    # 生成はi-1番目のbotが担当する。生成後は自分の初期位置に移動する
    def do_fission(i)
      @logger.debug("bot#{i}を生成します")
      parallel(i-1 => @bots[i-1].move_to(0, 0, 1) +        # 上にずれて、
                      [Fission.new(Nd.new(0, 0, -1),       # 原点に子供を生む
                                   @n_areas - i,
                                   new_bot_id: i,
                                   new_bot_pos: [0, 0, 0])])

      @logger.debug("bot#{i-1}を初期位置に配置します")
      x0, z0 = *@areas[20 - (i-1)][0]
      parallel(i-1 => @bots[i-1].move_to(x0, 0, z0))
    end

    # 天井にいるbotたちを原点にまとめる
    def do_fusions
      master_id = @bots.keys.max

      @logger.debug("botの回収処理を始めます。bot#{master_id}を原点に移動します")
      parallel(master_id => @bots[master_id].move_to(0, @model.max_y+1, 0) +
                            @bots[master_id].move_to(0, 0, 0))

      19.downto(1) do |id|
        do_fusion(id, master_id)
      end
    end

    def do_fusion(id, master_id)
      @logger.debug("bot#{id}を回収します。")
      cmds_list = Array.new(@bots.size){ [] }
      parallel(id => @bots[id].move_to(0, @model.max_y+1, 0) +
                     @bots[master_id].move_to(1, 0, 0))   # masterの右に移動
      parallel(master_id => [FusionP.new(Nd.new(1, 0, 0))],
               id        => [FusionS.new(Nd.new(-1, 0, 0))])
    end

    # ある層を出力する
    # y層の出力は、y+1層にいる状態で行う
    def print_layer(y)
      @logger.debug("y=#{y}の層を出力します")
      cmd_all{|bot| bot.move_by(0, 1, 0)}
      dir = +1 
      for z in @model.min_z..@model.max_z
        print_line(y, z, dir, z==@model.max_z)
        dir = -dir
      end
    end

    # 線を引くように動き、必要なmatterを配置する
    # 終わったあとは次の行にずれる
    # y: 線を引きたい層(nanobot自身はy+1にいるので注意)
    # dir: +1または-1
    def print_line(y, z, dir, is_last)
      @logger.debug("print_line: z=#{z} #{dir>0 ? 'forward' : 'backward'}")
      x_size = @model.max_x - @model.min_x + 1
      x_size.times do |i|
        cmd_all{|bot|
          cmds = []
          cmds << Fill.new(Nd.new(0, -1, 0)) if @model[bot.x, bot.y, bot.z] # 自分の真下を塗る
          cmds += bot.move_by(dir, 0, 0) unless i == x_size-1
          cmds
        }
      end

      unless is_last
        @logger.debug("次の行(z=#{z+1})に移動します")
        cmd_all{|bot| bot.move_by(0, 0, 1)}
      end
    end
  end
end
