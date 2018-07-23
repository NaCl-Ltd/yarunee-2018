# 実行するコマンドをバイナリへエンコードする  
class Nanobot
  class Encoder
    def initialize
      @traces = [String.new]
    end

    def encode(c)
      s = case c 
          when Command::Halt
            "11111111"
          when Command::Wait
            "11111110"
          when Command::Flip
            "11111101"
          when Command::SMove
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
            "00#{a}0100" + "000#{i.to_s(2).rjust(5, "0")}"
          when Command::Fill
            value = nd_val(c.nd)
            "#{value}011"
          when Command::Fission
            value = nd_val(c.nd)
            "#{value}101" + c.m.to_s(2).rjust(8, "0")
          when Command::FusionP
            value = nd_val(c.nd)
            "#{value}111"
          when Command::FusionS
            value = nd_val(c.nd)
            "#{value}110"
          when Command::Void
            value = nd_val(c.nd)
            "#{value}010"
          when Command::GFill
            nd_value = nd_val(c.nd)
            fd_value = fd_val(c.fd)
            "#{nd_value}001" + fd_value
          when Command::GVoid
            nd_value = nd_val(c.nd)
            fd_value = fd_val(c.fd)
            "#{nd_value}000" + fd_value
          else
            raise "不明なコマンドです"
          end
      return [s].pack("B*") 
    end

    def create_binaryfile(file_path)
      binary = @traces.pack("B*") 
      file = open(file_path, "wb")
      file.print(binary)
      puts "create a #{file_path}"
    end

    private
    def nd_val(nd)
      v = (nd.dx + 1) * 9 + (nd.dy + 1) * 3 + (nd.dz + 1)
      return v.to_s(2).rjust(5, '0')
    end

    def fd_val(fd)
      "#{_fd_val(fd.dx)}#{_fd_val(fd.dy)}#{_fd_val(fd.dz)}"
    end

    def _fd_val(d)
      (d + 30).to_s(2).rjust(8, '0')
    end
  end
end
