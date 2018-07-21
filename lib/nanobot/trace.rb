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
      File.write(nbt_path, TODO)
    end
  end
end
