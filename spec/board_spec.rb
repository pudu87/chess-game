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
    it "shows a game board" do
      expect(STDOUT).to receive(:puts).exactly(:once)
      expect(subject).to receive(:print).at_least(64).times
      subject.show
    end
  end 

  describe "#insert" do
    it "moves a piece to an empty spot" do
      subject.insert([[0,0],[1,0]])
      expect(subject.board[0][0]).to be_nil
      expect(subject.board[1][0]).to eql('bR')
    end
    it "moves a piece to an occupied spot" do
      subject.insert([[0,0],[3,0]])
      expect(subject.board[0][0]).to be_nil
      expect(subject.board[3][0]).to eql('bR')
      expect(subject.taken[-1]).to eql('wP')
    end
    it "performs castling" do
      subject.insert([[0,4],[0,2],[0,0],[0,3]])
      expect(subject.board[0][0]).to be_nil
      expect(subject.board[0][2]).to eql('bK')
      expect(subject.board[0][3]).to eql('bR')
    end
    it "performs an en-passant" do
      subject.insert([[3,7],[2,6],[3,6],nil])
      expect(subject.board[3][7]).to be_nil
      expect(subject.board[3][6]).to be_nil
      expect(subject.board[2][6]).to eql('wP')
      expect(subject.taken[-1]).to eql('bP')
    end
  end

  describe "#promotion" do
    it "transforms the pawn into the requested piece" do
      expect(STDOUT).to receive(:puts).twice
      allow(subject).to receive(:gets).and_return('R')
      subject.player = 'b'
      subject.promotion([7,3])
      expect(subject.board[7][3]).to eql('bR')
    end
  end

  describe "#valid_move?" do
    before do 
      n_board = subject.board
      subject.player = 'b'
    end
    it "returns true if move is possible" do
      allow(subject).to receive(:compute_moves).and_return([[[0,0], [0,1]]])
      allow(subject).to receive(:check?).and_return(false)
      expect(subject.valid_move?([[0,0], [0,1]])).to be_truthy
    end
    it "returns false if move results in a check" do
      allow(subject).to receive(:compute_moves).and_return([[[0,4], [0,5]]])
      allow(subject).to receive(:check?).and_return(true)
      expect(subject.valid_move?([[0,4], [0,5]])).not_to be_truthy
    end
    it "returns false if move is not allowed" do
      allow(subject).to receive(:compute_moves).and_return([[[0,4], [0,5]]])
      allow(subject).to receive(:check?).and_return(true)
      expect(subject.valid_move?([[0,0], [0,1]])).not_to be_truthy
    end
  end

  describe "#check?" do
    before { subject.player = 'b' }
    it "returns true if a player is in check" do
      allow(subject).to receive(:compute_moves).and_return([[[1,0], [0,0]], [[1,0], [0,1]], [[2,5], [0,4]]])
      n_board = subject.board
      expect(subject.check?(n_board)).to be_truthy
    end
    it "returns false if a player is not in check" do
      allow(subject).to receive(:compute_moves).and_return([[[1,0], [0,0]], [[1,0], [0,1]]])
      n_board = subject.board
      expect(subject.check?(n_board)).not_to be_truthy
    end
  end

  describe "#stalemate?" do
    it "returns true if there is a stalemate" do
      allow(subject).to receive(:compute_moves).and_return([[[0,0], [0,1]], [[0,0], [0,1]], [[0,0], [0,2]]])
      allow(subject).to receive(:valid_move?).exactly(3).times.and_return(false, false, false)
      expect(subject.stalemate?('b')).to be_truthy
    end
    it "returns false if there is no stalemate" do
      allow(subject).to receive(:compute_moves).and_return([[[0,0], [0,1]], [[0,0], [0,1]], [[0,0], [0,2]]])
      allow(subject).to receive(:valid_move?).exactly(3).times.and_return(false, false, true)
      expect(subject.stalemate?('b')).not_to be_truthy
    end
  end

  describe "#checkmate?" do
    before { subject.player = 'b' }
    it "returns true if there is a checkmate" do
      allow(subject).to receive(:compute_moves).and_return([[[0,0], [0,1]], [[0,0], [0,1]], [[0,0], [0,2]]])
      allow(subject).to receive(:check?).and_return(true)
      allow(subject).to receive(:valid_move?).exactly(3).times.and_return(false, false, false)
      expect(subject.checkmate?).to be_truthy
    end
    it "returns false if there is no checkmate" do
      allow(subject).to receive(:compute_moves).and_return([[[0,0], [0,1]], [[0,0], [0,1]], [[0,0], [0,2]]])
      allow(subject).to receive(:check?).and_return(false)
      allow(subject).to receive(:valid_move?).exactly(3).times.and_return(false, false, false)
      expect(subject.checkmate?).not_to be_truthy
    end
  end
  
end