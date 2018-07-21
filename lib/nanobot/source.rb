class Nanobot
  # テキスト形式のソースを扱うクラス
  class Source
    def self.load(source_path)
      new(File.read(source_path))
    end

    def initialize(source)
      # @voxels[y][z][x] で取り出す
      @voxels = source.split("\n\n").reverse.map{ |i| i.split.reverse.map(&:chars) }
      @resolution = @voxels.size
    end

    def to_mdl
      b = ""
      @resolution.times do |x|
        @resolution.times do |y|
          @resolution.times do |z|
            b += @voxels[y][z][x]
          end
        end
      end
      [@resolution].pack("C*") + [b].pack("b*")
    end
  end
end
