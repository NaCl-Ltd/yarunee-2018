class Nanobot
  # 形状データを表すクラス
  class Model
    # .mdlファイルを読み込む
    def self.load(mdl_path)
      new(File.binread(mdl_path))
    end

    # mdl: .mdlファイルの中身(String)
    def initialize(mdl)
      m = mdl.unpack("C*")
      @resolution = m[0]
      b = mdl.unpack("B*")[0]
      @voxels = b[8..-1]
    end

    # マップサイズを返す
    def resolution
      @resolution
    end

    # ある座標にmatterがあるとき真を返す
    def [](x, y, z)
      v = @voxels[x * @resolution * @resolution + y * @resolution + z]
      !v.nil? && v != "0"
    end
  end
end
