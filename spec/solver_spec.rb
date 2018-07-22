require 'spec_helper'

class Nanobot
  describe Solver do
    C = Command

    describe "#split_areas" do
      it "盤面が大きいとき" do
        model = Model.empty(100)
        solver = Solver.new(model)
        areas = solver.split_areas
        expect(areas.length).to eq(20)
        expect(areas[0]).to eq([[0, 0], [19, 24]])
        expect(areas[1]).to eq([[20, 0], [39, 24]])
        expect(areas[2]).to eq([[40, 0], [59, 24]])
        expect(areas[3]).to eq([[60, 0], [79, 24]])
        expect(areas[4]).to eq([[80, 0], [99, 24]])
        expect(areas[5]).to eq([[0, 25], [19, 49]])
        expect(areas[6]).to eq([[20, 25], [39, 49]])
        expect(areas[7]).to eq([[40, 25], [59, 49]])
        expect(areas[8]).to eq([[60, 25], [79, 49]])
        expect(areas[9]).to eq([[80, 25], [99, 49]])
        expect(areas[10]).to eq([[0, 50], [19, 74]])
        expect(areas[11]).to eq([[20, 50], [39, 74]])
        expect(areas[12]).to eq([[40, 50], [59, 74]])
        expect(areas[13]).to eq([[60, 50], [79, 74]])
        expect(areas[14]).to eq([[80, 50], [99, 74]])
        expect(areas[15]).to eq([[0, 75], [19, 99]])
        expect(areas[16]).to eq([[20, 75], [39, 99]])
        expect(areas[17]).to eq([[40, 75], [59, 99]])
        expect(areas[18]).to eq([[60, 75], [79, 99]])
        expect(areas[19]).to eq([[80, 75], [99, 99]])
      end

      it "盤面が5x5より小さいときはエラー" do
        model = Model.empty(4)
        solver = Solver.new(model)
        expect { solver.split_areas }.to raise_error(RuntimeError)
      end
    end

    describe "#parallel" do
      before do
        model = Model.empty(5)
        @solver = Solver.new(model)
        @solver.logger = Logger.new(nil)
      end

      it "長さが一番長いものに合わせてWaitを埋める" do
        @solver.instance_variable_set(:@bots, {3 => Bot.new(3), 5 => Bot.new(5)})
        @solver.send(:parallel, {
          3 => [C::Flip.new, C::Flip.new],
          5 => [C::Halt.new],
        })
        trace = @solver.instance_variable_get(:@trace)
        expect(trace.commands).to eq(
          [C::Flip.new, C::Halt.new, C::Flip.new, C::Wait.new]
        )
      end
    end
  end
end
