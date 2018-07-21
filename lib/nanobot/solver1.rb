require 'nanobot/solver'

class Nanobot
  # とりあえずvalidな解を出すためのソルバ
  class Solver1 < Solver
    def solve
      # 方針
      #
      # 各フロアについて以下を繰り返す
      #   次のmatter位置を調べる
      #   そこの隣に移動する
      #   そこにFillする
      # 後片付け
      #   botを原点に移動させる
      #   haltを出力

      cmd Halt.new
      return @trace
    end

    private

    # ある層を出力する
    def print_layer
    end

    # 原点に帰還する
    def return_to_origin

    end

    # ある座標に移動する
    def move_to(x, y, z)
      cmd LMove.new(Lld.new()
    end
  end
end
