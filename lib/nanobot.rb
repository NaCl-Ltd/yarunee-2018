require 'thor'
require 'nanobot/command'
require 'nanobot/model'
require 'nanobot/trace'

class Nanobot
  class Cli < Thor
    desc "now", "現在時刻を表示する"
    def now
      puts Time.now
    end
  end
end
