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

    def exec_trace(mdl_path, nbt_path, frame)
      @driver.navigate.to("https://icfpcontest2018.github.io/lgtn/exec-trace.html")
      input = @driver.find_element(id: "tgtModelFileIn")
      input.send_keys(File.expand_path(mdl_path))
      input = @driver.find_element(id: "traceFileIn")
      input.send_keys(File.expand_path(nbt_path))
      select = Selenium::WebDriver::Support::Select.new(@driver.find_element(id: "stepsPerFrame"))
      select.select_by(:value, frame.to_s)
      @driver.find_element(id: "execTrace").click
    end
  end
end
