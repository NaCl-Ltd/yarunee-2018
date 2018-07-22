require 'nanobot/command'

class Nanobot
  # 1台のnanobotを表すクラス(ソルバ用)
  class Bot
    include Command

    def initialize(id, x=0, y=0, z=0)
      @id, @x, @y, @z = id, x, y, z
    end
    attr_reader :id, :x, :y, :z

    # 移動(相対位置指定)
    def move_by(dx, dy, dz)
      move_to(@x+dx, @y+dy, @z+dz)
    end

    # ある座標に移動する
    # 現状ではSMoveのみ使用
    # y軸->x軸->z軸の順で移動処理を行う
    def move_to(x, y, z)
      cmds = []
      p "bot#{@id}: (#{@x},#{@y},#{@z})から(#{x},#{y},#{z})に移動します"
      dx, dy, dz = x-@x, y-@y, z-@z
      cmds += move_linear(1, dy.abs, dy/dy.abs) if dy != 0
      cmds += move_linear(0, dx.abs, dx/dx.abs) if dx != 0
      cmds += move_linear(2, dz.abs, dz/dz.abs) if dz != 0
      @x, @y, @z = x, y, z
      return cmds
    end

    # ある軸(idx)のある方向(dir)にamountだけ移動する
    def move_linear(idx, amount, dir)
      cmds = []
      while amount > 15
        cmds += move_linear(idx, 15, dir)
        amount -= 15
      end
      diff = [0, 0, 0]
      diff[idx] = amount * dir
      cmds << SMove.new(Lld.new(*diff))
      return cmds
    end
  end
end
