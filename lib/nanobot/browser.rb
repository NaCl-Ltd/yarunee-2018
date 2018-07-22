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
  end
end
