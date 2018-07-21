require 'thor'

class Nanobot < Thor

  desc "now", "現在時刻を表示する"
  def now
    puts Time.now
  end

end
