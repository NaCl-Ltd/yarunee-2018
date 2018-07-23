require 'pp'
require 'thor'
require 'nanobot/browser'
require 'nanobot/model'
require 'nanobot/trace'
require 'nanobot/source'
require 'nanobot/solver1'
require 'nanobot/solver2'
require 'nanobot/solver3'
require 'nanobot/solver4'
require 'pathname'

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
      trace.save(options[:file]) if options[:file]
    end

    desc "solver4", "Solver4を実行する"
    option :file, :type => :string
    def solver4(mdl_path)
      model = Model.load(mdl_path)
      solver = Solver4.new(model)
      trace = solver.solve
      trace.save(options[:file]) if options[:file]
    end

    desc "fa_solve_problems", "問題の解凍用のmslファイルを生成"
    def fa_solve_problems(m)
      m.to_i.step(186, 3) do |i|
        mdl_path = Pathname.new("files/problemsL/LA#{i.to_s.rjust(3, '0')}_tgt.mdl")
        model = Model.load(mdl_path.to_s)
        solver = Solver3.new(model)
        trace = solver.solve
        trace.save("submission/FA#{i.to_s.rjust(3, '0')}.nbt")
      end
    end

    desc "fd_solve_problems", "問題の解凍用のmslファイルを生成"
    def fd_solve_problems(m)
      m.to_i.step(186, 3) do |i|
        mdl_path = Pathname.new("files/problemsF/FD#{i.to_s.rjust(3, '0')}_src.mdl")
        model = Model.load(mdl_path.to_s)
        solver = Solver4.new(model)
        trace = solver.solve
        trace.save("submission/FD#{i.to_s.rjust(3, '0')}.nbt")
      end
    end

    desc "browse_model", ".mdlファイルをブラウザで開く"
    def browse_model(mdl_path)
      Browser.new.open_model(mdl_path)
      print "Press enter to finish"
      $stdin.gets
    end

    desc "lgtn_browse_trace", ".mdlと.nbtファイルのトレースをブラウザで開く"
    def lgtn_browse_trace(mdl_path, nbt_path, frame = '10')
      Browser.new.lgtn_exec_trace(mdl_path, nbt_path, frame)
      print "Press enter to finish"
      $stdin.gets
    end

    desc "browse_trace", ".mdlと.nbtファイルのトレースをブラウザで開く"
    def browse_trace(nbt_path, src_path = nil, tgt_path = nil, frame = '10')
      Browser.new.exec_trace(src_path, tgt_path, nbt_path, frame)
      print "Press enter to finish"
      $stdin.gets
    end

    desc "list_maps", "問題の一覧を表示"
    def list_maps
      Dir["#{__dir__}/../files/problemsL/LA*_tgt.mdl"].each do |path|
        model = Model.load(path)
        puts "#{File.basename(path)}: r=#{model.resolution}"
        $stdout.flush
      end
    end
  end
end
