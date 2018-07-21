class Nanobot
  # 形状データを表すクラス
  class Model
    # .mdlファイルを読み込む
    def load(mdl_path)
      new(File.read(mdl_path)
    end

    # mdl: .mdlファイルの中身(String)
    def initialize(mdl)
    end
  end
end
