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

      def cmd_name
        self.class.name.split(/::/).last
      end

      def inspect
        cmd_name
      end
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
      attr_reader :lld

      def ==(other)
        other.class == self.class && self.lld == other.lld
      end

      def inspect
        "#{cmd_name}(#{@lld.dx} #{@lld.dy} #{@lld.dz})"
      end
    end

    class LMove < Base
    end

    class Fission < Base
      def initialize(nd, m)
        @nd, @m = nd, m
      end
      attr_reader :nd, :m

      def ==(other)
        other.class == self.class && self.nd == other.nd && self.m == other.m
      end

      def inspect
        "#{cmd_name}(#{@nd.dx} #{@nd.dy} #{@nd.dz} m=#{@m})"
      end
    end

    class Fill < Base
      def initialize(nd)
        @nd = nd
      end
      attr_reader :nd

      def ==(other)
        other.class == self.class && self.nd == other.nd
      end

      def inspect
        "#{cmd_name}(#{@nd.dx} #{@nd.dy} #{@nd.dz})"
      end
    end

    class FusionP < Base
      def initialize(nd)
        @nd = nd
      end
      attr_reader :nd

      def ==(other)
        other.class == self.class && self.nd == other.nd
      end

      def inspect
        "#{cmd_name}(#{@nd.dx} #{@nd.dy} #{@nd.dz})"
      end
    end

    class FusionS < Base
      def initialize(nd)
        @nd = nd
      end
      attr_reader :nd

      def ==(other)
        other.class == self.class && self.nd == other.nd
      end

      def inspect
        "#{cmd_name}(#{@nd.dx} #{@nd.dy} #{@nd.dz})"
      end
    end
  end
end
