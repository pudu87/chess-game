require './lib/game.rb'

RSpec.describe Game do

  describe "#game" do
    let(:board) { subject.board }
    before do
      expect(STDOUT).to receive(:puts).exactly(3).times.with(instance_of(String))
      allow(subject).to receive(:input).and_return(nil)
      allow(subject).to receive(:switch_player).and_return(nil)
      allow(board).to receive(:show).and_return(nil)
    end
    context "enters the game loop when called" do
      it "and stops when there is a checkmate or stalemate" do
        allow(board).to receive(:check?).and_return(true)
        allow(board).to receive(:stalemate?).and_return(false, false, true)
        expect(board).to receive(:stalemate?).exactly(3).times
        subject.game
      end
    end
  end

  describe "#switch_player" do
    it "switches player to black if white" do
      subject.player = 'w'
      expect(subject.switch_player).to eql('b')
    end
    it "switches player to white if black" do
      subject.player = 'b'
      expect(subject.switch_player).to eql('w')
    end
  end

end