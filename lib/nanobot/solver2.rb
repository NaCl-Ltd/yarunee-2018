require 'nanobot/solver'

class Nanobot
  # Solver1のマイナーチェンジバージョン
  # 出力したい層の一段上に浮いて作業することでコードを簡単にした
  class Solver2 < Solver
    def initialize(*args)
      super
      @r = @model.resolution
      if @model.max_y == @r-1
        raise "一番上までmatterが詰まっているマップは解けません(;_;)"
      end
      if @model.min_x == 0 || @model.min_z == 0
        raise "原点の上にmatterがあるマップは解けません(;_;)"
      end
      @x, @y, @z = 0, 0, 0
    end

    def solve
      cmd(Flip.new) if high_harmonics_needed?
      for y in 0..@model.max_y
        print_layer(y)
      end
      @logger.debug("終わったので原点に戻ります")
      move_to(0, @y, 0)
      move_to(0, 0, 0)
      cmd(Flip.new) if high_harmonics_needed?
      cmd(Halt.new)
      return @trace
    end

    def nbt_save(file_path)
      @trace.save(file_path)
    end

    private

    # ある層を出力する
    # y層の出力は、y+1層にいる状態で行う
    def print_layer(y)
      @logger.debug("y=#{y}の層を出力します")
      move_to(0, y+1, 0)
      dir = +1 
      for z in @model.min_z..@model.max_z
        print_line(y, z, dir)
        dir = -dir
      end
    end

    # 線を引くように動き、必要なmatterを配置する
    # 終わったあとは次の行にずれる
    # y: 線を引きたい層(nanobot自身はy+1にいるので注意)
    # dir: +1または-1
    def print_line(y, z, dir)
      @logger.debug("print_line: z=#{z} #{dir>0 ? 'forward' : 'backward'}")
      x = @x
      loop do
        break if (dir > 0 && x > @model.max_x) ||
                 (dir < 0 && x < @model.min_x)
        move_to(x, y+1, z)
        if @model[x, y, z]
          cmd(Fill.new(Nd.new(0, -1, 0)))  # 自分の真下を塗る
        end
        x += dir
      end
      @logger.debug("次の行(z=#{z+1})に移動します")
      move_to(@x, y+1, z+1)
    end

    # ある座標に移動する(SMoveのみ使用)
    # y軸->z軸->x軸の順で移動処理を行う
    def move_to(x, y, z)
      @logger.debug("(#{@x},#{@y},#{@z})から(#{x},#{y},#{z})に移動します")
      dx, dy, dz = x-@x, y-@y, z-@z
      move_linear(1, dy.abs, dy/dy.abs) if dy != 0
      move_linear(2, dz.abs, dz/dz.abs) if dz != 0
      move_linear(0, dx.abs, dx/dx.abs) if dx != 0
      @x, @y, @z = x, y, z
    end

    # ある軸(idx)のある方向(dir)にamountだけ移動する
    def move_linear(idx, amount, dir)
      while amount > 15
        move_linear(idx, 15, dir)
        amount -= 15
      end
      diff = [0, 0, 0]
      diff[idx] = amount * dir
      cmd(SMove.new(Lld.new(*diff)))
    end
  end
end

