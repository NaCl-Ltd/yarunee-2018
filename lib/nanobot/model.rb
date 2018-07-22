class Nanobot
  # 形状データを表すクラス
  class Model
    # .mdlファイルを読み込む
    def self.load(mdl_path)
      new(File.binread(mdl_path))
    end

    # 全マスがVoidなモデルを生成する
    def self.empty(resolution)
      raise ArgumentError if resolution <= 0
      b = "0" * resolution**3
      mdl = [resolution].pack("C*") + [b].pack("b*")
      new(mdl)
    end

    # mdl: .mdlファイルの中身(String)
    def initialize(mdl)
      m = mdl.unpack("C*")
      @resolution = m[0]
      b = mdl.unpack("b*")[0]
      @voxels = b[8..-1]
      calc_bounding_box
    end
    attr_reader :max_y, :min_x, :min_z, :max_x, :max_z, :x_size, :y_size, :z_size

    # マップサイズを返す
    def resolution
      @resolution
    end

    # ある座標にmatterがあるとき真を返す
    def [](x, y, z)
      v = @voxels[x * @resolution * @resolution + y * @resolution + z]
      !v.nil? && v != "0"
    end

    def to_source
      s = Array.new(@resolution) { Array.new(@resolution) { Array.new(@resolution) }}
      @resolution.times do |x|
        @resolution.times do |y|
          @resolution.times do |z|
            s[y][z][x] = @voxels[x * @resolution * @resolution + y * @resolution + z]
          end
        end
      end
      s.reverse!
      @resolution.times do |y|
        s[y] = s[y].reverse
        @resolution.times do |z|
          s[y][z] = s[y][z].join
        end
        s[y] = s[y].join("\n")
      end
      s.join("\n\n")
    end

    # ひさし(突き出している部分)があるとき真を返す
    def has_eaves?
      (1..@resolution-1).any? { |y|
        (0..@resolution-1).any? { |x|
          (0..@resolution-1).any? { |z|
            self[x, y, z] ? (self[x, y-1, z] ? false : true) : false
          }
        }
      }
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
      @x_size = @max_x - @min_x + 1
      @y_size = @max_y + 1
      @z_size = @max_z - @min_z + 1
    end
  end
end
