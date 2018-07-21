require 'spec_helper'
class Nanobot
  describe Model do
    MDL1_PATH = "#{__dir__}/../files/problemsL/LA001_tgt.mdl"
    SAMPLE1_PATH = "#{__dir__}/../sample/models/1.mdl"

    describe ".load" do
      it ".mdlファイルを読み込める" do
        model = Model.load(MDL1_PATH)
        expect(model).to be_a(Model)
      end
    end

    describe "#min_y" do
      it "matterがあるマスのy座標の最小値を返す" do
        model = Model.load(SAMPLE1_PATH)
        expect(model.min_y).to eq(1)
      end
    end
  end
end
