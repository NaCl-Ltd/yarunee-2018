class Nanobot
  # 形状データを表すクラス
  class Model
    # .mdlファイルを読み込む
    def self.load(mdl_path)
      new(File.read(mdl_path))
    end

    # mdl: .mdlファイルの中身(String)
    def initialize(mdl)
    end

    # マップサイズを返す
    def resolution
      TODO
    end

    # ある座標にmatterがあるとき真を返す
    def [](x, y, z)
      TODO
    end
  end
end
