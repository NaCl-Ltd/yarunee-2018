class Nanobot
  # Far distance
  class Fd
    # TODO: LdやLldのようなチェックを入れる
    def initialize(dx, dy, dz)
      @dx, @dy, @dz = dx, dy, dz
    end
    attr_reader :dx, :dy, :dz
  end
end
