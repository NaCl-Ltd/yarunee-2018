require 'nanobot/solver'

class Nanobot
  # 破壊を行うソルバ
  class Solver4 < Solver
    # 最初のbotがseedを何番まで持っているか
    N_INITIAL_SEEDS = 40
    # 破壊する正方形のサイズ
    SQUARE_SIZE = 15
    # ボットの陣形
    BOT_POS = {
      1 => [0, 0],
      2 => [SQUARE_SIZE+1, 0],
      3 => [0, SQUARE_SIZE+1],
      4 => [SQUARE_SIZE+1, SQUARE_SIZE+1],
    }
    # GVoidするときの始点の相対座標
    GVOID_SQUARE_ARGS = {
      1 => [Nd.new( 1, 0,  1), Fd.new( SQUARE_SIZE, 0,  SQUARE_SIZE)],
      2 => [Nd.new(-1, 0,  1), Fd.new(-SQUARE_SIZE, 0,  SQUARE_SIZE)],
      3 => [Nd.new( 1, 0, -1), Fd.new( SQUARE_SIZE, 0, -SQUARE_SIZE)],
      4 => [Nd.new(-1, 0, -1), Fd.new(-SQUARE_SIZE, 0, -SQUARE_SIZE)],
    }
    # 横線を消すときの引数
    GVOID_ROWS_ARGS = {
      1 => [Nd.new( 1, 0,  0), Fd.new( SQUARE_SIZE, 0,  0)],
      2 => [Nd.new(-1, 0,  0), Fd.new(-SQUARE_SIZE, 0,  0)],
      3 => [Nd.new( 1, 0,  0), Fd.new( SQUARE_SIZE, 0,  0)],
      4 => [Nd.new(-1, 0,  0), Fd.new(-SQUARE_SIZE, 0,  0)],
    }
    # 縦線を消すときの引数
    GVOID_COLS_ARGS = {
      1 => [Nd.new( 0, 0,  1), Fd.new(0, 0,  SQUARE_SIZE)],
      3 => [Nd.new( 0, 0, -1), Fd.new(0, 0, -SQUARE_SIZE)],
      2 => [Nd.new( 0, 0,  1), Fd.new(0, 0,  SQUARE_SIZE)],
      4 => [Nd.new( 0, 0, -1), Fd.new(0, 0, -SQUARE_SIZE)],
    }

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
      @ceiling_y = @model.max_y + 1
    end

    def solve
      cmd(Flip.new) if high_harmonics_needed?
      do_fissions
      do_deconstruction
      do_fusions
      @logger.debug("破壊作業が完了しました")
      cmd(Flip.new) if high_harmonics_needed?
      cmd(Halt.new)
      return @trace
    end

    private

    # 分裂を行い、各botを初期位置に配置する
    def do_fissions
      for i in 2..4
        do_fission(i)
        move_to_initial_position(i-1)
      end
      move_to_initial_position(4)
    end

    # i番目のbotの生成処理を行う
    # 生成はi-1番目のbotが担当する。生成後は自分の初期位置に移動する
    def do_fission(i)
      @logger.debug("bot#{i}を生成します")
      parallel(i-1 => @bots[i-1].move_to(0, 0, 1) +        # 上にずれて、
                      [Fission.new(Nd.new(0, 0, -1),       # 原点に子供を生む
                                   N_INITIAL_SEEDS - i - 1,
                                   new_bot_id: i,
                                   new_bot_pos: [0, 0, 0])])
    end

    # i番目のbotを初期位置に移動させる
    def move_to_initial_position(i)
      @logger.debug("bot#{i}を初期位置に配置します")
      dx, dz = *BOT_POS[i]
      parallel(i => @bots[i].move_to(@model.min_x+dx, @ceiling_y, @model.min_z+dz))
    end

    # 天井にいるbotたちを原点にまとめる
    def do_fusions
      master_id = @bots.keys.max

      @logger.debug("botの回収処理を始めます。bot#{master_id}を原点に移動します")
      parallel(master_id => @bots[master_id].move_to(0, @model.max_y+1, 0) +
                            @bots[master_id].move_to(0, 0, 0))

      (@areas.size-1).downto(1) do |id|
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

    # 破壊処理本体
    def do_deconstruction
      # 破壊エリアの隅
      dig_x, dig_z = @model.min_x, @model.min_z
      while dig_z+SQUARE_SIZE+1 <= @model.max_z
        while dig_x+SQUARE_SIZE+1 <= @model.max_x
          dig_area(dig_x, dig_z)
          dig_x += SQUARE_SIZE+1
        end
        dig_z += SQUARE_SIZE+1
      end
    end

    # あるエリアを破壊する
    def dig_area(dig_x, dig_z)
      TODO: botを初期位置に移動する処理
      @logger.debug("エリア(#{dig_x}, #{dig_z})の破壊を開始します")
      dig_y = @model.max_y
      loop do
        dig_y = next_dig_y(dig_x, dig_y, dig_z)
        break unless dig_y
        dig_plane(dig_x, dig_y, dig_z)
      end
    end

    # 次に破壊すべき面のy座標を返す。床まで掘れている場合はnilを返す
    def next_dig_y(dig_x, y, dig_z)
      while y > 0
        return y if matter_in_plane?(dig_x, y, dig_z)
        y -= 1
      end
      return nil
    end

    # 平面内にmatterがあるとき真を返す
    def matter_in_plane?(dig_x, dig_y, dig_z)
      for x in dig_x..(dig_x+SQUARE_SIZE+1)
        for z in dig_z..(dig_z+SQUARE_SIZE+1)
          return true if @model[x, dig_y, z]
        end
      end
      return false
    end

    # ある平面を破壊する
    def dig_plane(dig_x, dig_y, dig_z)
      place_bots_in_plane(dig_x, dig_y, dig_z)
      cmd_all{|bot|
        [GVoid.new(*GVOID_SQUARE_ARGS[bot.id])]
      }
      cmd_all{|bot|
        [GVoid.new(*GVOID_ROWS_ARGS[bot.id])]
      }
      cmd_all{|bot|
        [GVoid.new(*GVOID_COLS_ARGS[bot.id])]
      }
    end

    # botを平面に埋める
    def place_bots_in_plane(dig_x, dig_y, dig_z)
      cmd_all{|bot|
        bot.move_by(0, dig_y - @bot.y + 1, 0)
      }
      cmd_all{|bot|
        if @model[bot.x, dig_y, bot.z]
          [Void.new(Nd.new(0, -1, 0))]
        else
          []
        end
      }
      cmd_all{|bot|
        bot.move_by(0, -1, 0)
      }
    end

    # ----

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
      finished_bot_ids = @bots.select{|id, bot| layer_empty?(bot, y)}.keys.to_set
      dir = +1
      @area_z_size.times do |dz|
        print_line(dir, dz, finished_bot_ids)
        dir = -dir
      end
    end

    # あるボットの担当範囲のy層部分が空のとき真を返す
    def layer_empty?(bot, y)
      (x1, z1), (x2, z2) = *@areas[@areas.length-bot.id]
      for x in x1..x2
        for z in z1..z2
          return false if @model[x, y, z]
        end
      end
      return true
    end

    # 線を引くように動き、必要なmatterを配置する
    # 終わったあとは次の行にずれる
    # dir: +1または-1
    # dz: 何番目の線か(0~)
    # finished_bot_ids: 層が空だったので作業が必要ないbotたち
    def print_line(dir, dz, finished_bot_ids)
      @logger.debug("print_line: #{dz}本目 #{dir>0 ? 'forward' : 'backward'}")
      @area_x_size.times do |dx|
        cmd_all{|bot|
          if finished_bot_ids.include?(bot.id)
            []
          else
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
          end
        }
      end

      @logger.debug("次の行(#{dz+1}本目)に移動します")
      cmd_all{|bot|
        if finished_bot_ids.include?(bot.id)
          []
        else
          # 自分が担当するエリア
          (x1, z1), (x2, z2) = *@areas[@areas.length-bot.id]
          z_size = z2-z1+1
          if dz < z_size-1
            bot.move_by(0, 0, 1)
          else
            []
          end
        end
      }
    end
  end
end
