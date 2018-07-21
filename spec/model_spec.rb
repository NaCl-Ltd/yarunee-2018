require 'spec_helper'
class Nanobot
  describe Model do
    MDL1_PATH = "#{__dir__}/../files/problemsL/LA001_tgt.mdl"

    describe ".load" do
      it ".mdlファイルを読み込める" do
        model = Model.load(MDL1_PATH)
        expect(model).to be_a(Model)
      end
    end
  end
end
