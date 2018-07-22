require 'spec_helper'

class Nanobot
  describe Solver do
    describe "#split_areas" do
      it "盤面が大きいとき" do
        model = TODO: 100x100のマップがあるとする
        solver = Solver.new(model)
        areas = solver.split_areas
        expect(areas.length).to eq(20)
        expect(areas[0]).to eq([[0, 0], [19, 24]])
        expect(areas[1]).to eq([[20, 0], [39, 24]])
        expect(areas[19]).to eq([[80, 75], [99, 99]])
      end

      it "盤面が5x5より小さいときはエラー" do
        TODO
      end
    end
  end
end
