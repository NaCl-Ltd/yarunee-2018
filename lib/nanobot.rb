require 'thor'
require 'nanobot/model'
require 'nanobot/trace'
require 'nanobot/source'
require 'nanobot/solver1'

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

    desc "solver1", "Solver1を実行する"
    def solver1(mdl_path)
      model = Model.load(mdl_path)
      trace = Solver1.new(model).solve
      p trace
    end
  end
end
