require 'spec_helper'
class Nanobot
  describe Model do
    MDL1_PATH = "#{__dir__}/../files/problemsL/LA001_tgt.mdl"
    SAMPLE1_PATH = "#{__dir__}/../sample/models/1.mdl"
    SAMPLE2_PATH = "#{__dir__}/../sample/models/2.mdl"
    SAMPLE3_PATH = "#{__dir__}/../sample/models/3.mdl"

    describe ".load" do
      it ".mdlファイルを読み込める" do
        model = Model.load(MDL1_PATH)
        expect(model).to be_a(Model)
      end
    end

    describe ".empty" do
      it "サイズ1" do
        model = Model.empty(1)
        expect(model.resolution).to eq(1)
        expect(model[0,0,0]).to eq(false)
      end

      it "サイズ2" do
        model = Model.empty(2)
        expect(model.resolution).to eq(2)
        expect(model[1,1,1]).to eq(false)
      end
    end

    describe "#has_eaves?" do
      it "真の場合" do
        model = Model.load(SAMPLE3_PATH)
        expect(model.has_eaves?).to eq(true)
      end

      it "偽の場合" do
        model = Model.load(SAMPLE2_PATH)
        expect(model.has_eaves?).to eq(false)
      end
    end

    describe "bounding boxes" do
      it "座標の最小値を返す" do
        model = Model.load(SAMPLE2_PATH)
        expect(model.min_x).to eq(1)
        expect(model.max_x).to eq(2)
        expect(model.min_z).to eq(1)
        expect(model.max_z).to eq(2)
        expect(model.max_y).to eq(2)
      end
    end
  end
end
