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
        expect(areas[19]).to eq([[80, 75], [99, 99]])
      end

      it "盤面が5x5より小さいときはエラー" do
        TODO
      end
    end

    describe "#parallel" do
      it "長さが一番長いものに合わせてWaitを埋める" do
        model = Model.empty(100)
        solver = Solver.new(model)
        solver.logger = Logger.new(nil)
        solver.instance_variable_set(:@bots, {3 => Bot.new(3), 5 => Bot.new(5)})
        solver.send(:parallel, [
          [C::Flip.new, C::Flip.new],
          [C::Halt.new],
        ])
        trace = solver.instance_variable_get(:@trace)
        expect(trace.commands).to eq(
          [C::Flip.new, C::Halt.new, C::Flip.new, C::Wait.new]
        )
      end
    end
  end
end
