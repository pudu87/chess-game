require './lib/board.rb'

RSpec.describe Board do
  
  before do 
    subject.board = [ 
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

  describe "#show" do
    xit "shows a game board" do
      expect(STDOUT).to receive(:puts).at_least(:twice)
      expect(subject).to receive(:print).at_least(64).times
      subject.show
    end
  end 

  describe "#insert" do
    xit "moves a piece to an empty spot" do
      subject.insert([[0,0],[1,0]])
      expect(subject.board[0][0]).to be_nil
      expect(subject.board[1][0]).to eql('bR')
    end
    xit "moves a piece to an occupied spot" do
      subject.insert([[0,0],[3,0]])
      expect(subject.board[0][0]).to be_nil
      expect(subject.board[3][0]).to eql('bR')
      expect(subject.taken[-1]).to eql('wP')
    end
    xit "performs castling" do
      subject.insert([[0,4],[0,2],[0,0],[0,3]])
      expect(subject.board[0][0]).to be_nil
      expect(subject.board[0][2]).to eql('bK')
      expect(subject.board[0][3]).to eql('bR')
    end
    xit "performs an en-passant" do
      subject.insert([[3,7],[2,6],[3,6],nil])
      expect(subject.board[3][7]).to be_nil
      expect(subject.board[3][6]).to be_nil
      expect(subject.board[2][6]).to eql('wP')
    end
  end

  describe "#promotion?" do
    xit "returns true if pawn is eligible for promotion" do
      expect(subject.promotion?([7,3])).to be_truthy
    end
    xit "returns false if pawn is not eligible for promotion" do
      expect(subject.promotion?([3,0])).not_to be_truthy
    end
  end

  describe "#promotion" do
    xit "transforms the pawn into the requested piece" do
      expect(STDOUT).to receive(:puts)
      allow(subject).to receive(:gets).and_return('R')
      subject.promotion([7,3])
      expect(board[7][3]).to eql('bR')
    end
  end

  describe "#valid_move?" do
    before { n_board = subject.board }
    xit "returns true if move is possible" do
      allow(subject).to receive(:move).and_return([[0,0], [0,1]])
      allow(subject).to receive(:check?).and_return(false)
      expect(subject.valid_move?([[0,0], [0,1]],'b')).to be_truthy
    end
    xit "returns false if move results in a check" do
      allow(subject).to receive(:move).and_return([[0,4], [0,5]])
      allow(subject).to receive(:check?).and_return(true)
      expect(subject.valid_move?([[0,4], [0,5]],'b')).not_to be_truthy
    end
  end

  describe "#check?" do
    before { subject.player = 'b' }
    xit "returns true if a player is in check" do
      allow(subject).to receive(:move).and_return([[[1,0], [0,0]], [[1,0], [0,1]], [[2,5], [0,4]]])
      expect(subject.check?(moves)).to be_truthy
    end
    xit "returns false if a player is not in check" do
      allow(subject).to receive(:move).and_return([[[1,0], [0,0]], [[1,0], [0,1]]])
      expect(subject.check?(moves)).not_to be_truthy
    end
  end

  describe "#stalemate?" do
    before { subject.player = 'b' }
    xit "returns true if there is a stalemate" do
      allow(subject).to receive(:move).and_return([[[0,0], [0,1]], [[0,0], [0,1]], [[0,0], [0,2]]])
      allow(subject).to receive(:valid_move?).exactly(3).times.and_return(false, false, false)
      expect(stalemate?('b')).to be_truthy
    end
    xit "returns false if there is no stalemate" do
      allow(subject).to receive(:move).and_return([[[0,0], [0,1]], [[0,0], [0,1]], [[0,0], [0,2]]])
      allow(subject).to receive(:valid_move?).exactly(3).times.and_return(false, false, true)
      expect(stalemate?('b')).not_to be_truthy
    end
  end

  describe "#checkmate?" do
    before { subject.player = 'b' }
    xit "returns true if there is a checkmate" do
      allow(subject).to receive(:move).and_return([[[0,0], [0,1]], [[0,0], [0,1]], [[0,0], [0,2]]]
      allow(subject).to receive(:check?).and_return(true)
      allow(subject).to receive(:valid_move?).exactly(3).times.and_return(false, false, false)
      expext(subject.checkmate?('b')).to be_truthy
    end
      xit "returns false if there is no checkmate" do
        allow(subject).to receive(:move).and_return([[[0,0], [0,1]], [[0,0], [0,1]], [[0,0], [0,2]]])
        allow(subject).to receive(:check?).and_return(false)
        allow(subject).to receive(:valid_move?).exactly(3).times.and_return(false, false, false)
        expext(subject.checkmate?('b')).not_to be_truthy
      end
    end
  end
  
end