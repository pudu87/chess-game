require './lib/moves.rb'

class Dummyclass
  include Moves
  attr_accessor :board, :history, :player
  def check?(*)
  end
end

RSpec.describe Moves do
  let(:dummy) { Dummyclass.new }
  before do 
    dummy.player = 'w'
    dummy.history = [[[7,4],[6,4]]]
    dummy.board = 
      [
      [ 'bR', nil , nil , nil , 'bK', nil , nil , 'bR'],
      [ nil , nil , nil , nil , 'bP', nil , nil , nil ],
      [ nil , 'bP', nil , nil , nil , nil , nil , nil ],
      [ 'wP', 'bH', nil , nil , nil , nil , 'bP', 'wP'],
      [ nil , 'wP', 'bP', nil , nil , nil , nil , nil ],
      [ 'wH', nil , nil , nil , 'wB', nil , nil , nil ],
      [ nil , nil , nil , nil , 'wK', 'wQ', nil , nil ],
      [ 'wR', nil , nil , 'bP', nil , nil , nil , 'wR']
      ]
    end

  describe "#compute_moves" do
    it "returns all possible moves for black" do
      dummy.player = 'b'
      dummy.history = [[[6,1],[4,1]]]
      expect(dummy.compute_moves).to match_array(
        [ [[0,0],[0,1]], [[0,0],[0,2]], [[0,0],[0,3]], [[0,0],[1,0]], 
            [[0,0],[2,0]], [[0,0],[3,0]],
          [[0,4],[0,5]], [[0,4],[1,5]], [[0,4],[1,3]], [[0,4],[0,3]], 
            [[0,4],[0,2],[0,0],[0,3]], [[0,4],[0,6],[0,7],[0,5]],
          [[0,7],[1,7]], [[0,7],[2,7]], [[0,7],[3,7]], [[0,7],[0,6]], 
            [[0,7],[0,5]],
          [[1,4],[2,4]], [[1,4],[3,4]],
          [[2,1],[3,0]],
          [[3,1],[1,2]], [[3,1],[2,3]], [[3,1],[4,3]], [[3,1],[5,2]], 
            [[3,1],[5,0]], [[3,1],[1,0]],
          [[3,6],[4,6]],
          [[4,2],[5,2]], [[4,2],[5,1],[4,1],nil]
        ]
      )
    end
    it "returns all possible moves for white" do
      expect(dummy.compute_moves).to match_array(
        [ [[3,0],[2,0]], [[3,0],[2,1]],
          [[3,7],[2,7]],
          [[5,0],[3,1]], [[5,0],[4,2]], [[5,0],[6,2]], [[5,0],[7,1]],
          [[5,4],[4,5]], [[5,4],[3,6]], [[5,4],[6,3]], [[5,4],[7,2]], 
            [[5,4],[4,3]], [[5,4],[3,2]], [[5,4],[2,1]],
          [[6,4],[5,5]], [[6,4],[7,5]], [[6,4],[7,4]], [[6,4],[7,3]], 
            [[6,4],[6,3]], [[6,4],[5,3]],
          [[6,5],[5,5]], [[6,5],[4,5]], [[6,5],[3,5]], [[6,5],[2,5]], 
            [[6,5],[1,5]], [[6,5],[0,5]], [[6,5],[5,6]], [[6,5],[4,7]], 
            [[6,5],[6,6]], [[6,5],[6,7]], [[6,5],[7,6]], [[6,5],[7,5]], 
            [[6,5],[7,4]],
          [[7,0],[6,0]], [[7,0],[7,1]], [[7,0],[7,2]], [[7,0],[7,3]],
          [[7,7],[6,7]], [[7,7],[5,7]], [[7,7],[4,7]], [[7,7],[7,6]], 
            [[7,7],[7,5]], [[7,7],[7,4]], [[7,7],[7,3]]
        ]
      )
    end
  end

  describe "#pawn" do
    context "returns all possible moves for a pawn" do
      it "when it can't move" do
        expect(dummy.pawn([4,1])).to eql([]) 
      end
      it "when it can move" do
        dummy.player = 'b'
        expect(dummy.pawn([2,1])).to eql([[[2,1],[3,0]]])
      end
      it "when it can advance 2 squares" do
        dummy.player = 'b'
        expect(dummy.pawn([1,4])).to match_array([[[1,4],[2,4]], [[1,4],[3,4]]])
      end
      it "when it can perform an en-passant" do
        dummy.history = [[[7,1],[7,0]], [[0,1],[0,0]], [[4,7],[3,7]], [[1,6],[3,6]]]
        expect(dummy.pawn([3,7])).to match_array([[[3,7],[2,7]], [[3,7],[2,6],[3,6],nil]],)
      end
    end
  end

  describe "#king" do
    before { dummy.player = 'b' }
    it "returns all possible moves for a king" do
      expect(dummy.king([0,4])).to match_array([[[0,4],[0,3]], [[0,4],[1,3]], 
        [[0,4],[1,5]], [[0,4],[0,5]], [[0,4],[0,2],[0,0],[0,3]], [[0,4],[0,6],[0,7],[0,5]]])
    end
    it "does not allow castling if the king already moved" do
      dummy.history = [[[7,0],[7,1]], [[0,3],[0,4]], [[7,1],[7,0]]]
      expect(dummy.king([0,4])).to match_array([[[0,4],[0,3]], [[0,4],[1,3]], 
        [[0,4],[1,5]], [[0,4],[0,5]]])
    end
    it "does not allow castling if there are pieces in between" do
      dummy.board[0][2] = 'bB'
      expect(dummy.king([0,4])).to match_array([[[0,4],[0,3]], [[0,4],[1,3]], 
        [[0,4],[1,5]], [[0,4],[0,5]], [[0,4],[0,6],[0,7],[0,5]]])
    end
  end

  describe "#queen" do
    it "returns all possible moves for a queen" do
      expect(dummy.queen([6,5])).to match_array([[[6,5],[5,5]], [[6,5],[4,5]], 
        [[6,5],[3,5]], [[6,5],[2,5]], [[6,5],[1,5]], [[6,5],[0,5]], 
        [[6,5],[5,6]], [[6,5],[4,7]], [[6,5],[6,6]], [[6,5],[6,7]], 
        [[6,5],[7,6]], [[6,5],[7,5]], [[6,5],[7,4]]])
    end
  end

  describe "#bishop" do
    it "returns all possible moves for a bishop" do
      expect(dummy.bishop([5,4])).to match_array([[[5,4],[4,5]], [[5,4],[3,6]], 
        [[5,4],[6,3]], [[5,4],[7,2]], [[5,4],[4,3]], [[5,4],[3,2]], [[5,4],[2,1]]])
    end
  end

  describe "#rook" do
    it "returns all possible moves for a rook" do
      dummy.player = 'b'
      expect(dummy.rook([0,0])).to match_array([[[0,0],[0,1]], [[0,0],[0,2]], 
        [[0,0],[0,3]], [[0,0],[1,0]], [[0,0],[2,0]], [[0,0],[3,0]]])
    end
  end

  describe "#knight" do
    it "returns all possible moves for a knight" do
      dummy.player = 'b'
      expect(dummy.knight([3,1])).to match_array([[[3,1],[1,2]], [[3,1],[2,3]], 
        [[3,1],[4,3]], [[3,1],[5,2]], [[3,1],[5,0]],[[3,1],[1,0]]])
    end
  end

end