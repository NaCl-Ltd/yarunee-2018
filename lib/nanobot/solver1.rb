require 'nanobot/solver'

class Nanobot
  # とりあえずvalidな解を出すためのソルバ
  # 前提条件
  #   空間の一番外側(=天井および外周)のマスにmatterがないこと
  #   (最初のいくつかの問題はそうなっていたが、全部かは不明)
  class Solver1 < Solver
    def initialize(*args)
      super
      @r = @model.resolution
      if @model.max_y == @r-1
        raise "一番上までmatterが詰まっているマップは解けません(;_;)"
      end
      if @model.min_x == 0 || @model.min_z == 0 ||
         @model.max_x == @r-1 || @model.max_z == @r-1
        raise "外周までmatterが詰まっているマップは解けません(;_;)"
      end
      @x, @y, @z = 0, 0, 0
    end

    def solve
      cmd(Flip.new) if high_harmonics_needed?
      for y in 0..@model.max_y
        print_layer(y)
      end
      @logger.debug("終わったので原点に戻ります")
      move_to(0, 0, 0)
      cmd(Flip.new) if high_harmonics_needed?
      cmd(Halt.new)
      return @trace
    end

    private

    def high_harmonics_needed?
      true
      # TODO: 下がVoidであるmatterが存在するときだけ真を返すようにする
    end

    # ある層を出力する
    # 終わったあとは次の層の(0, 0)に移動する
    def print_layer(y)
      @logger.debug("y=#{y}の層を出力します")
      dir = +1 
      for z in @model.min_z..@model.max_z
        print_line(y, z, dir)
        dir = -dir
      end
      @logger.debug("y=#{y+1}の層に移動します")
      move_to(0, y+1, 0)
    end

    # 線を引くように動き、必要なmatterを配置する
    # 終わったあとは次の行にずれる
    # dir: +1または-1
    def print_line(y, z, dir)
      @logger.debug("print_line: z=#{z} #{dir>0 ? 'forward' : 'backward'}")
      x = @x
      loop do
        break if (dir > 0 && x > @model.max_x+1) ||
                 (dir < 0 && x < @model.min_x-1)
        move_to(x, y, z)
        if @model[x-dir, y, z]
          cmd(Fill.new(Nd.new(dir, 0, 0)))
        end
        x += dir
      end
      @logger.debug("次の行(z=#{z+1})に移動します")
      move_to(@x, y, z+1)
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
