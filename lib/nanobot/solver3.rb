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
      # エリアの最大サイズ(端数により、エリアのサイズが一致しない可能性があるので注意)
      @area_x_size = @areas.map{|(x1, z1), (x2, z2)| x2-x1+1}.max
      @area_z_size = @areas.map{|(x1, z1), (x2, z2)| z2-z1+1}.max
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
      parallel(id => @bots[id].move_to(1, @model.max_y+1, 0) +
                     @bots[id].move_to(1, 0, 0))   # masterの右に移動
      parallel(master_id => [FusionP.new(Nd.new(1, 0, 0))],
               id        => [FusionS.new(Nd.new(-1, 0, 0))])
    end

    # ある層を出力する
    # y層の出力は、y+1層にいる状態で行う
    def print_layer(y)
      if @model.max_y > 100 && y % (@model.max_y/10) == 0
        @logger.info("y=#{y}の層を出力します(max_y: #{@model.max_y})")
      end
      @logger.debug("y=#{y}の層を出力します")
      cmd_all{|bot|
        x1, z1 = *@areas[@areas.length-bot.id][0]
        bot.move_by(0, 1, 0) +
        bot.move_to(x1, bot.y, z1)
      }
      dir = +1 
      @area_z_size.times do |dz|
        print_line(dir, dz)
        dir = -dir
      end
    end

    # 線を引くように動き、必要なmatterを配置する
    # 終わったあとは次の行にずれる
    # dir: +1または-1
    # dz: 何番目の線か(0~)
    def print_line(dir, dz)
      @logger.debug("print_line: #{dz}本目 #{dir>0 ? 'forward' : 'backward'}")
      @area_x_size.times do |dx|
        cmd_all{|bot|
          cmds = []
          # 自分が担当するエリア
          (x1, z1), (x2, z2) = *@areas[@areas.length-bot.id]
          x_size = x2-x1+1

          if dx < x_size
            cmds << Fill.new(Nd.new(0, -1, 0)) if @model[bot.x, bot.y-1, bot.z] # 自分の真下を塗る
          end
          if dx < x_size-1
            cmds += bot.move_by(dir, 0, 0)
          end

          cmds
        }
      end

      @logger.debug("次の行(#{dz+1}本目)に移動します")
      cmd_all{|bot|
        # 自分が担当するエリア
        (x1, z1), (x2, z2) = *@areas[@areas.length-bot.id]
        z_size = z2-z1+1
        if dz < z_size-1
          bot.move_by(0, 0, 1)
        else
          []
        end
      }
    end
  end
end
