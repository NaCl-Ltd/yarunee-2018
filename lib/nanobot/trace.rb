require "nanobot/encoder"
class Nanobot
  # 命令列を表すクラス
  class Trace
    def initialize
      @commands = []
    end

    # Commandを追加する
    def add_commands(*cmds)
      @commands.concat(cmds)
    end

    # .nbtファイルに命令列を書き出す
    def save(nbt_path)
      encoder = Encoder.new
      encoder.parse(@commands)
      encoder.create_binaryfile(nbt_path)
    end
  end
end
