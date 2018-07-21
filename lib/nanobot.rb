require 'thor'
require 'nanobot/command'
require 'nanobot/model'
require 'nanobot/trace'
require 'nanobot/source'

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

    desc "create_mdl", "mdlファイル用バイナリ"
    def create_mdl(source_path)
      model = Source.load(source_path)
      print model.to_mdl
    end

    desc "to_source", "mdlファイルをsource形式にする"
    def to_source(mdl_path)
      model = Model.load(mdl_path)
      puts model.to_source
    end
  end
end
