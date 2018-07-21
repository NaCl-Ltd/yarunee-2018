require 'spec_helper'
class Nanobot
  describe Model do
    MDL1_PATH = "#{__dir__}/../files/problemsL/LA001_tgt.mdl"
    SAMPLE1_PATH = "#{__dir__}/../sample/models/1.mdl"
    SAMPLE2_PATH = "#{__dir__}/../sample/models/2.mdl"

    describe ".load" do
      it ".mdlファイルを読み込める" do
        model = Model.load(MDL1_PATH)
        expect(model).to be_a(Model)
      end
    end

    describe "bounding boxes" do
      it "座標の最小値を返す" do
        model = Model.load(SAMPLE2_PATH)
        expect(model.min_x).to eq(1)
        expect(model.max_x).to eq(2)
        expect(model.min_z).to eq(1)
        expect(model.max_z).to eq(2)
        expect(model.height).to eq(2)
      end
    end
  end
end
