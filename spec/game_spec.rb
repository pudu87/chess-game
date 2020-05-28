require './lib/game.rb'

RSpec.describe Game do

  describe "#game" do
    let(:board) { subject.board }
    before do
      expect(STDOUT).to receive(:puts).with(instance_of(String))
      allow(subject).to receive(:input).and_return(nil)
      allow(subject).to receive(:switch_player).and_return(nil)
      allow(board).to receive(:show).and_return(nil)
    end
    context "enters the game loop when called" do
      xit "and stops when there is a checkmate" do
        allow(board).to receive(:checkmate?).and_return(false, false, true)
        allow(board).to receive(:stalemate?).and_return(false, false)
        expect(board).to receive(:checkmate?).exactly(3).times
        subject.game
      end
      xit "and stops when there is a stalemate" do
        allow(board).to receive(:checkmate?).and_return(false, false, false)
        allow(board).to receive(:stalemate?).and_return(false, false, true)
        expect(board).to receive(:checkmate?).exactly(3).times
        subject.game
      end
    end
  end

  describe "#switch_player" do
    xit "switches player to black if white" do
      subject.player = 'w'
      expect(subject.switch_player).to eql('b')
    end
    xit "switches player to white if black" do
      subject.player = 'b'
      expect(subject.switch_player).to eql('w')
    end
  end

end