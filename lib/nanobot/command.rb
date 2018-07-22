require 'nanobot/lld'
require 'nanobot/nd'

class Nanobot
  # ナノボットへの命令を表すクラス
  module Command
    # 全コマンドの共通処理(あれば)
    class Base
      def ==(other)
        self.class == other.class
      end
    end

    class Halt < Base
      def inspect
        "Halt"
      end
    end

    class Wait < Base
      def inspect
        "Wait"
      end
    end

    class Flip < Base
      def inspect
        "Flip"
      end
    end

    class SMove < Base
      def initialize(lld)
        @lld = lld
      end

      def ==(other)
        other.is_a?(SMove) && self.lld == other.lld
      end

      def inspect
        "SMove(#{@lld.dx} #{@lld.dy} #{@lld.dz})"
      end

      def lld
        @lld
      end
    end

    class LMove < Base
    end

    class Fission < Base
    end

    class Fill < Base
      def initialize(nd)
        @nd = nd
      end

      def ==(other)
        other.is_a?(Fill) && self.nd == other.nd
      end

      def inspect
        "Fill(#{@nd.dx} #{@nd.dy} #{@nd.dz})"
      end

      def nd
        @nd
      end
    end

    class FusionP < Base
    end

    class FusionS < Base
    end
  end
end
