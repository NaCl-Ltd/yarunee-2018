class Nanobot
  # Near distance
  class Nd
    # TODO: LdやLldのようなチェックを入れる
    def initialize(dx, dy, dz)
      @dx, @dy, @dz = dx, dy, dz
    end
    attr_reader :dx, :dy, :dz
  end
end
