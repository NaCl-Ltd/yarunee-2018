require 'spec_helper'
require 'nanobot/solver1'
class Nanobot
  describe Solver1 do
    describe "#solve" do
      it "1matterのマップを解ける" do
        model = Model.load("#{__dir__}/../sample/models/1.mdl")
        solver = Solver1.new(model)
        solver.logger = Logger.new(nil)
        trace = solver.solve()
        expect(trace).to be_a(Trace)
      end
    end
  end
end
