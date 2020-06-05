module Moves

  PIECES = { 'P' => :pawn, 'K' => :king, 'Q' => :queen, 
             'B' => :bishop, 'R' => :rook, 'H' => :knight }
  MOVESET_Q = [[0,1], [0,-1], [1,0], [-1,0], [1,1], [1,-1], [-1,1], [-1,-1]]
  MOVESET_B = [[1,1], [1,-1], [-1,1], [-1,-1]]
  MOVESET_R = [[0,1], [0,-1], [1,0], [-1,0]]
  MOVESET_H = [[-2,-1], [-2,1], [-1,-2], [-1,2], [1,-2], [1,2], [2,-1], [2,1]]
  MOVESETS = { king: MOVESET_Q, queen: MOVESET_Q, bishop: MOVESET_B, 
               rook: MOVESET_R, knight: MOVESET_H }

  def compute_moves
    moves = []
    board.each_index do |y|
      board[y].each_index do |x|
        if board[y][x] && board[y][x][0] == player
          moves << send(PIECES[board[y][x][1]], [y,x])
        end
      end
    end
    moves.flatten(1)
  end

  [:queen, :bishop, :rook].each do |method|
    define_method(method) do |xy, moves=[]|
      moveset = MOVESETS[method]
      moveset.each do |m|
        ab = []
        ab[0] = xy[0] + m[0]
        ab[1] = xy[1] + m[1]
        until out_of_board?(ab) || other_piece?(ab)
          moves << [xy, [ab[0],ab[1]]]
          break if board[ab[0]][ab[1]]
          ab[0] += m[0]
          ab[1] += m[1]
        end
      end
    moves
    end
  end

  [:king, :knight].each do |method|
    define_method(method) do |xy, moves=[]|
      moveset = MOVESETS[method]
      moveset.each do |m|
        ab = []
        ab[0] = xy[0] + m[0]
        ab[1] = xy[1] + m[1]
        moves << [xy, ab] unless out_of_board?(ab) || other_piece?(ab)
      end
      castling(xy, moves) if method == :king
      moves   
    end
  end

  def pawn(xy, moves=[])
    player == 'w' ? s = -1 : s = 1
    forward_move(xy, moves, s) unless out_of_board?([xy[0] + 1*s, xy[1]])
    capture_move(xy, moves, s) unless out_of_board?([xy[0] + 1*s, xy[1]])
    en_passant(xy, moves, s)
    moves
  end

  private

  def out_of_board?(ab)
    !(0...8).include?(ab[0]) || !(0...8).include?(ab[1])
  end

  def other_piece?(ab)
    board[ab[0]][ab[1]] && player == board[ab[0]][ab[1]][0] ? true : false
  end

  def castling(xy, moves)
    { -1 => 0, 1 => 7 }.each do |k, r|
      unless moved?(xy, r) || pieces_in_between?(xy, k)
        moves << [xy, [xy[0], xy[1] + k*2], [xy[0], r], [xy[0], xy[1] + k]]
      end
    end
  end

  def moved?(xy, r)
    !(history.flatten(1) & [xy, [xy[0], r]]).empty?
  end

  def pieces_in_between?(xy, k)
    k < 0 ? board[xy[0]][xy[1]-1] || board[xy[0]][xy[1]-2] || board[xy[0]][xy[1]-3] :
            board[xy[0]][xy[1]+1] || board[xy[0]][xy[1]+2]
  end

  def forward_move(xy, moves, s)
    unless board[xy[0] + 1*s][xy[1]]
      moves << [xy, [xy[0] + 1*s, xy[1]]]
      unless board[xy[0] + 2*s][xy[1]] || history.any? { |m| m.include?(xy) }
        #xy[0] + 2.5*s != 3.5
        moves << [xy, [xy[0] + 2*s, xy[1]]]
      end
    end
  end

  def capture_move(xy, moves, s)
    [-1,1].each do |e|
      if board[xy[0] + 1*s][xy[1] + e] =~ /[^#{player}]./
        moves << [xy, [xy[0] + 1*s, xy[1] + e]]
      end
    end
  end

  def en_passant(xy, moves, s)
    [-1,1].each do |e|
      if (board[xy[0]][xy[1] + e] =~ /[^#{player}]P/ && 
          history[-1] == [[xy[0]+2*s, xy[1]+e],[xy[0], xy[1]+e]])
        moves << [xy, [xy[0] + 1*s, xy[1]+e], [xy[0], xy[1]+e], nil]
      end
    end
  end

end