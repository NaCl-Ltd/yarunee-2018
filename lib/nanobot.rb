require 'thor'
require 'nanobot/command'
require 'nanobot/model'
require 'nanobot/trace'

class Nanobot
  class Cli < Thor
    desc "now", "現在時刻を表示する"
    def now
      puts Time.now
    end

    desc "load", "読み込みテスト用コマンド"
    def load(mdl_path)
      model = Model.load(mdl_path)
      puts "loaded #{mdl_path}"
      puts "resolution: #{model.resolution}"
    end
  end
end
