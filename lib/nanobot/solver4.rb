require 'nanobot/solver'

class Nanobot
  # 破壊を行うソルバ
  class Solver4 < Solver
    # 最初のbotがseedを何番まで持っているか
    N_INITIAL_SEEDS = 40
    # 破壊する正方形のサイズ
    SQUARE_SIZE = 16
    # ボットの陣形
    #   3  1
    #   4  2
    BOT_POS = proc{|x_size, z_size| {
      4 => [0, 0],
      2 => [x_size+1, 0],
      3 => [0, z_size+1],
      1 => [x_size+1, z_size+1],
    }}
    # GVoidするときの始点の相対座標
    GVOID_SQUARE_ARGS = proc{|x_size, z_size| {
      4 => [Nd.new( 1, 0,  1), Fd.new(  x_size-1 , 0,   z_size-1)],
      2 => [Nd.new(-1, 0,  1), Fd.new(-(x_size-1), 0,   z_size-1)],
      3 => [Nd.new( 1, 0, -1), Fd.new(  x_size-1 , 0, -(z_size-1))],
      1 => [Nd.new(-1, 0, -1), Fd.new(-(x_size-1), 0, -(z_size-1))],
    }}
    # 横線を消すときの引数
    GVOID_ROWS_ARGS = proc{|x_size, z_size| {
      4 => [Nd.new( 1, 0,  0), Fd.new( (x_size-1), 0,  0)],
      2 => [Nd.new(-1, 0,  0), Fd.new(-(x_size-1), 0,  0)],
      3 => [Nd.new( 1, 0,  0), Fd.new( (x_size-1), 0,  0)],
      1 => [Nd.new(-1, 0,  0), Fd.new(-(x_size-1), 0,  0)],
    }}
    # 縦線を消すときの引数
    GVOID_COLS_ARGS = proc{|x_size, z_size| {
      4 => [Nd.new( 0, 0,  1), Fd.new(0, 0,  (z_size-1))],
      3 => [Nd.new( 0, 0, -1), Fd.new(0, 0, -(z_size-1))],
      2 => [Nd.new( 0, 0,  1), Fd.new(0, 0,  (z_size-1))],
      1 => [Nd.new( 0, 0, -1), Fd.new(0, 0, -(z_size-1))],
    }}

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

    def solve(recon_mode: false)
      cmd(Flip.new) if high_harmonics_needed?
      do_fissions
      do_deconstruction
      do_fusions
      @logger.debug("破壊作業が完了しました")
      unless recon_mode
        cmd(Flip.new) if high_harmonics_needed?
        cmd(Halt.new)
      end
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
                                   N_INITIAL_SEEDS - i,
                                   new_bot_id: i,
                                   new_bot_pos: [0, 0, 0])])
    end

    # i番目のbotを初期位置に移動させる
    def move_to_initial_position(i)
      @logger.debug("bot#{i}を初期位置に配置します")
      x_size = [SQUARE_SIZE, @model.max_x-@model.min_x-1].min
      z_size = [SQUARE_SIZE, @model.max_z-@model.min_z-1].min
      dx, dz = *BOT_POS[x_size, z_size][i]
      parallel(i => @bots[i].move_to(@model.min_x+dx, @ceiling_y, @model.min_z+dz))
    end

    # 作業終了したbotたちを原点にまとめる
    def do_fusions
      master_id = 1

      @logger.debug("botの回収処理を始めます。bot#{master_id}を原点に移動します")
      tmp_y = @bots[master_id].y == 0 ? 1 : 0
      parallel(master_id => @bots[master_id].move_to(0, tmp_y, 0) +
                            @bots[master_id].move_to(0, 0, 0))

      (2..4).each do |id|
        do_fusion(id, master_id, tmp_y)
      end
    end

    def do_fusion(id, master_id, tmp_y)
      @logger.debug("bot#{id}を回収します。")
      cmds_list = Array.new(@bots.size){ [] }
      parallel(id => @bots[id].move_to(1, tmp_y, 0) +
                     @bots[id].move_to(1, 0, 0))   # masterの右に移動
      parallel(master_id => [FusionP.new(Nd.new(1, 0, 0))],
               id        => [FusionS.new(Nd.new(-1, 0, 0))])
    end

    # 破壊処理本体
    def do_deconstruction
      # 破壊エリアの隅
      dig_z = @model.min_z
      while dig_z <= @model.max_z
        z_size = [SQUARE_SIZE, @model.max_z-dig_z-1].min
        dig_x = @model.min_x
        while dig_x <= @model.max_x
          x_size = [SQUARE_SIZE, @model.max_x-dig_x-1].min
          @logger.debug("エリア(#{dig_x}, #{dig_z})(#{x_size}x#{z_size})の上空にbotを移動します")
          cmd_all{|bot|
            dx, dz = *BOT_POS[x_size, z_size][bot.id]
            bot.move_to(dig_x+dx, @ceiling_y, dig_z+dz)
          }
          dig_area(dig_x, dig_z, x_size, z_size)
          dig_x += SQUARE_SIZE
        end
        dig_z += SQUARE_SIZE
      end
    end

    # あるエリアを破壊する
    def dig_area(dig_x, dig_z, x_size, z_size)
      @logger.debug("エリア(#{dig_x}, #{dig_z})(#{x_size}x#{z_size})の破壊を開始します")
      dig_y = @model.max_y
      loop do
        dig_y = next_dig_y(dig_x, dig_y, dig_z, x_size, z_size)
        break unless dig_y
        dig_plane(dig_x, dig_y, dig_z, x_size, z_size)
        dig_y -= 1
      end
    end

    # 次に破壊すべき面のy座標を返す。床まで掘れている場合はnilを返す
    def next_dig_y(dig_x, y, dig_z, x_size, z_size)
      while y >= 0
        return y if matter_in_plane?(dig_x, y, dig_z, x_size, z_size)
        y -= 1
      end
      return nil
    end

    # 平面内にmatterがあるとき真を返す
    def matter_in_plane?(dig_x, dig_y, dig_z, x_size, z_size)
      for x in dig_x..(dig_x+x_size+1)
        for z in dig_z..(dig_z+z_size+1)
          return true if @model[x, dig_y, z]
        end
      end
      return false
    end

    # ある平面を破壊する
    def dig_plane(dig_x, dig_y, dig_z, x_size, z_size)
      #@logger.debug("y=#{dig_y}の面を破壊します")
      place_bots_in_plane(dig_x, dig_y, dig_z)
      if x_size>0 && z_size>0
        cmd_all{|bot|
          [GVoid.new(*GVOID_SQUARE_ARGS[x_size, z_size][bot.id])]
        }
      end
      if x_size>0
        cmd_all{|bot|
          [GVoid.new(*GVOID_ROWS_ARGS[x_size, z_size][bot.id])]
        }
      end
      if z_size>0
        cmd_all{|bot|
          [GVoid.new(*GVOID_COLS_ARGS[x_size, z_size][bot.id])]
        }
      end
    end

    # botを平面に埋める
    def place_bots_in_plane(dig_x, dig_y, dig_z)
      cmd_all{|bot|
        bot.move_by(0, dig_y - bot.y + 1, 0)
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
  end
end
