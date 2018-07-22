require "nanobot/encoder"
class Nanobot
  # 命令列を表すクラス
  class Trace
    def initialize
      @nbt_data = ""
      @encoder = Encoder.new
    end

    # Commandを追加する
    def add_commands(*cmds)
      cmds.each do |c|
        unless Command::Base === c
          raise "コマンドではありません：#{c.inspect}"
        end
        @nbt_data << @encoder.encode(c)
      end
    end

    # .nbtファイルに命令列を書き出す
    def save(nbt_path)
      File.binwrite(nbt_path, @nbt_data)
    end
  end
end
