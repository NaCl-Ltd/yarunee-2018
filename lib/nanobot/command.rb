class Nanobot
  # ナノボットへの命令を表すクラス
  class Command
    class Halt < Command
    end

    class Wait < Command
    end

    class Flip < Command
    end

    class SMove < Command
    end

    class LMove < Command
    end

    class Fission < Command
    end

    class Fill < Command
    end

    class FusionP < Command
    end

    class FusionS < Command
    end
  end
end
