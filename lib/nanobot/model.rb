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
    attr_reader :height, :min_x, :min_y, :max_x, :max_y

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
        for y in 0...resolution
          for z in 0...resolution
            next true if self[x, y, z]
          end
        end
        false
      }
      @min_y = (0...resolution).find{|y|
        for x in 0...resolution
          for z in 0...resolution
            next true if self[x, y, z]
          end
        end
        false
      }
      @max_x = (0...resolution).to_a.reverse.find{|x|
        for y in 0...resolution
          for z in 0...resolution
            next true if self[x, y, z]
          end
        end
        false
      }
      @max_y = (0...resolution).to_a.reverse.find{|y|
        for x in 0...resolution
          for z in 0...resolution
            next true if self[x, y, z]
          end
        end
        false
      }
      @height = (0...resolution).to_a.reverse.find{|z|
        for x in 0...resolution
          for y in 0...resolution
            next true if self[x, y, z]
          end
        end
        false
      }
    end
  end
end
