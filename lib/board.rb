require_relative 'moves.rb'

class Board
  include Moves

  SHOW = { 'wK' => "\u2654", 'wQ' => "\u2655", 'wR' => "\u2656",
           'wB' => "\u2657", 'wH' => "\u2658", 'wP' => "\u2659",
           'bK' => "\u265A", 'bQ' => "\u265B", 'bR' => "\u265C",
           'bB' => "\u265D", 'bH' => "\u265E", 'bP' => "\u265F",
            nil => " " }

  attr_accessor :board, :history, :taken, :player, :move

  def initialize
    @board = Array.new(8) { Array.new(8) }
      board[0] = %w[bR bH bB bQ bK bB bH bR]
      board[1] = %w[bP bP bP bP bP bP bP bP]
      board[6] = %w[wP wP wP wP wP wP wP wP]
      board[7] = %w[wR wH wB wQ wK wB wH wR]
    @history = []
    @taken = []
    @player = 'w'
  end

  def show
    print "\n   "
    8.times { |n| print "  #{(n+65).chr} " }
    print "          TAKEN:"
    
    board.each_with_index do |row, i|
      print "\n   "
      8.times { print " ---" }
      print "\n #{8-i} "
      row.each do |e|
        print "| #{SHOW[e]} "
      end
      print "| #{8-i}"
      print "       #{SHOW[taken[i]]}" if taken[i]
      print "   #{SHOW[taken[i+8]]}" if taken[i+8]
      print "   #{SHOW[taken[i+16]]}" if taken[i+16]
      print "   #{SHOW[taken[i+24]]}" if taken[i+24]
    end
    print "\n   "
    8.times { print " ---" }

    print "\n   "
    8.times { |n| print "  #{(n+65).chr} " }
    puts
  end

  def valid_move?(suggested_move, moves=nil)
    moves ||= compute_moves
    @move = nil
    moves.each { |m| @move = m if suggested_move == m[0..1] }
    move ? temp_board = create_temp_board(move) : (return false)
    return false if move[3] && castling_squares_attacked?(move)
    !check?(temp_board)
  end

  def check?(board=@board, king=nil)
    king ||= find_king(board)
    enemy_moves = compute_enemy_moves(board)
    enemy_moves.any? { |move| move[1] == king }
  end

  def stalemate?
    moves = compute_moves
    moves.none? { |move| valid_move?(move, moves) }
  end

  def insert
    a, b, c, d = move[0], move[1], move[2], move[3]
    if d
      insert_castling(a, b, c, d)
    elsif c
      taken << board[c[0]][c[1]]
      insert_en_passant(a, b, c)
    else
      taken << board[b[0]][b[1]] if board[b[0]][b[1]]
      insert_regular(a, b)
    end
    history << [a, b]
    promotion(b) if (board[b[0]][b[1]][1] == 'P' && [0,7].include?(b[0]))
  end

  def promotion(xy)
    puts "Promotion! Pick an upgrade for your pawn:"
    puts "Q(ueen), R(ook), B(ishop) or K(night)?"
    pick = gets.chomp.upcase
    until ['Q', 'R', 'B', 'K'].include?(pick)
      puts "Unvalid choice. Insert Q, R, B or K."
      pick = gets.chomp.upcase
    end
    board[xy[0]][xy[1]] = "#{player}#{pick}"
  end

  private

  def insert_regular(a, b, board=@board)
    board[b[0]][b[1]] = board[a[0]][a[1]]
    board[a[0]][a[1]] = nil
  end

  def insert_castling(a, b, c, d, board=@board)
    board[b[0]][b[1]] = board[a[0]][a[1]]
    board[d[0]][d[1]] = board[c[0]][c[1]]
    board[a[0]][a[1]] = nil
    board[c[0]][c[1]] = nil
  end

  def insert_en_passant(a, b, c, board=@board)
    board[b[0]][b[1]] = board[a[0]][a[1]]
    board[a[0]][a[1]] = nil
    board[c[0]][c[1]] = nil
  end

  def find_king(board)
    board.each_with_index do |row, r_ind|
      c_ind = row.index("#{player}K")
      return [r_ind, c_ind] if c_ind
    end
  end

  def create_temp_board(move)
    a, b, c, d = move[0], move[1], move[2], move[3]
    temp_board = Marshal.load(Marshal.dump(board))
    case
    when d then insert_castling(a, b, c, d, temp_board)
    when c then insert_en_passant(a, b, c, temp_board)
    else insert_regular(a, b, temp_board)
    end
    temp_board
  end

  def castling_squares_attacked?(move)
    check?(board, move[0]) || check?(board, move[3])
  end

  def compute_enemy_moves(temp_board)
    player == 'b' ? @player = 'w' : @player = 'b'
    @board, temp_board = temp_board, board
    moves = compute_moves
    @board, temp_board = temp_board, board
    player == 'b' ? @player = 'w' : @player = 'b'
    moves
  end

end