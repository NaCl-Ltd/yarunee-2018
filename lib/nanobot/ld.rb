class Nanobot
  # Linear distance
  class Ld
    # 直線的であるとき真を返す
    def self.valid?(dx, dy, dz)
      (dx != 0 && dy != 0) ||
      (dy != 0 && dz != 0) ||
      (dz != 0 && dx != 0)
    end

    # マンハッタン距離を返す
    def self.mlen(dx, dy, dz)
      dx.abs + dy.abs + dz.abs
    end

    def initialize(dx, dy, dz)
      if !Ld.valid?(dx, dy, dz)
        raise "Ldとして不正です：(#{dx}, #{dy}, #{dz})"
      end
      @dx, @dy, @dz = dx, dy, dz
    end
  end
end
