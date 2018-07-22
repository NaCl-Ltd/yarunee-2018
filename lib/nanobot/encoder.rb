# 実行するコマンドをバイナリへエンコードする  
class Nanobot
  class Encoder
    def initialize
      @traces = []    
    end
  
    def parse(command)
      command.each do |c|
        case c 
        when Halt
          @traces << "11111111"
        when Flip
          @traces << "11111101"
        when SMove
          lld = c.lld
          if !lld.dx.zero?
            a = "01"
            i = lld.dx + 15
          elsif !lld.dy.zero?
            a = "10"
            i = lld.dy + 15
          elsif !lld.dz.zero?
            a = "11"
            i = lld.dz + 15
          end
          @traces << "00#{a}0100" + "000#{i.to_s(2).rjust(5, "0")}"
        when Fill
          nd = c.nd
          value = (nd.dx + 1) * 9 + (nd.dy + 1) * 3 + (nd.dz + 1)
          @traces << "#{value.to_s(2).rjust(5, '0')}0011"
        end 
      end
    end
  end
end
