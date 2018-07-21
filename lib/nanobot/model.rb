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
      calc_bounding_box
    end
    attr_reader :max_y, :min_x, :min_z, :max_x, :max_z

    # マップサイズを返す
    def resolution
      @resolution
    end

    # ある座標にmatterがあるとき真を返す
    def [](x, y, z)
      v = @voxels[x * @resolution * @resolution + y * @resolution + z]
      !v.nil? && v != "0"
    end

    private
    
    # bounding boxを計算する
    def calc_bounding_box
      @min_x = (0...resolution).find{|x|
        (0...resolution).any?{|y| (0...resolution).any?{|z| self[x, y, z] }}
      }
      @min_z = (0...resolution).find{|z|
        (0...resolution).any?{|x| (0...resolution).any?{|y| self[x, y, z] }}
      }
      @max_x = (0...resolution).to_a.reverse.find{|x|
        (0...resolution).any?{|y| (0...resolution).any?{|z| self[x, y, z] }}
      }
      @max_z = (0...resolution).to_a.reverse.find{|z|
        (0...resolution).any?{|x| (0...resolution).any?{|y| self[x, y, z] }}
      }
      @max_y = (0...resolution).to_a.reverse.find{|y|
        (0...resolution).any?{|x| (0...resolution).any?{|z| self[x, y, z] }}
      }
    end
  end
end
