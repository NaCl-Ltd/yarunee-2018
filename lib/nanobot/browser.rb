require "selenium-webdriver"

class Nanobot
  # ブラウザでオフィシャルのビジュアライザを開くためのクラス
  class Browser
    def initialize
      @driver = Selenium::WebDriver.for(:safari)
    end

    def open_model(mdl_path)
      @driver.navigate.to("https://icfpcontest2018.github.io/view-model.html")
      input = @driver.find_element(id: "modelFileIn")
      input.send_keys(File.expand_path(mdl_path))
    end

    def lgtn_exec_trace(mdl_path, nbt_path, frame)
      @driver.navigate.to("https://icfpcontest2018.github.io/lgtn/exec-trace.html")
      input = @driver.find_element(id: "tgtModelFileIn")
      input.send_keys(File.expand_path(mdl_path))
      input = @driver.find_element(id: "traceFileIn")
      input.send_keys(File.expand_path(nbt_path))
      select = Selenium::WebDriver::Support::Select.new(@driver.find_element(id: "stepsPerFrame"))
      select.select_by(:value, frame.to_s)
      @driver.find_element(id: "execTrace").click
    end

    def exec_trace(src_path, tgt_path, nbt_path, frame)
      @driver.navigate.to("https://icfpcontest2018.github.io/full/exec-trace.html")
      if src_path != nil && src_path != ''
        input = @driver.find_element(id: "srcModelFileIn")
        input.send_keys(File.expand_path(src_path))
      else
        @driver.find_element(id: "srcModelEmpty").click
      end
      if tgt_path != nil && tgt_path != ''
        input = @driver.find_element(id: "tgtModelFileIn")
        input.send_keys(File.expand_path(tgt_path))
      else
        @driver.find_element(id: "tgtModelEmpty").click
      end
      input = @driver.find_element(id: "traceFileIn")
      input.send_keys(File.expand_path(nbt_path))
      select = Selenium::WebDriver::Support::Select.new(@driver.find_element(id: "stepsPerFrame"))
      select.select_by(:value, frame.to_s)
      @driver.find_element(id: "execTrace").click
    end
  end
end
