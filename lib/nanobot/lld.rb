require 'nanobot/ld'

class Nanobot
  # Long linear distance
  class Lld
    # Lldの範囲におさまっているとき真を返す
    def self.valid?(dx, dy, dz)
      mlen(dx, dy, dz) <= 15
    end

    def initialize(dx, dy, dz)
      super
      if !Lld.valid?(dx, dy, dz)
        raise "Lldとして不正です：(#{dx}, #{dy}, #{dz})"
      end
      @dx, @dy, @dz = dx, dy, dz
    end
  end
end
