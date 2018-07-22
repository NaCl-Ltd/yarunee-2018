require 'thor'
require 'nanobot/browser'
require 'nanobot/model'
require 'nanobot/trace'
require 'nanobot/source'
require 'nanobot/solver1'
require 'nanobot/solver2'
require 'nanobot/solver3'

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

    desc "solver2", "Solver2を実行する"
    option :file, :type => :string
    def solver2(mdl_path)
      model = Model.load(mdl_path)
      solver2 = Solver2.new(model)
      trace = solver2.solve
      p trace
      solver2.nbt_save(options[:file]) if options[:file]
    end

    desc "solver3", "Solver3を実行する"
    option :file, :type => :string
    def solver3(mdl_path)
      model = Model.load(mdl_path)
      solver = Solver3.new(model)
      trace = solver.solve
      p trace
      solver.nbt_save(options[:file]) if options[:file]
    end

    desc "browse_model", ".mdlファイルをブラウザで開く"
    def browse_model(mdl_path)
      Browser.new.open_model(mdl_path)
      print "Press enter to finish"
      $stdin.gets
    end

    desc "browse_trace", ".mdlと.nbtファイルのトレースをブラウザで開く"
    def browse_trace(mdl_path, nbt_path, frame = '10')
      Browser.new.exec_trace(mdl_path, nbt_path, frame)
      print "Press enter to finish"
      $stdin.gets
    end
  end
end
