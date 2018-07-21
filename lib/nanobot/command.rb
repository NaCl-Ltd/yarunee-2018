require 'nanobot/lld'
require 'nanobot/nd'

class Nanobot
  # ナノボットへの命令を表すクラス
  module Command
    # 全コマンドの共通処理(あれば)
    class Base
    end

    class Halt < Base
    end

    class Wait < Base
    end

    class Flip < Base
    end

    class SMove < Base
      def initialize(lld)
        @lld = lld
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
    end

    class FusionP < Base
    end

    class FusionS < Base
    end
  end
end
