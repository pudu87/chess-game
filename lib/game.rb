require_relative 'board.rb'
require_relative 'save.rb'

class Game
  include Save

  attr_accessor :board, :player, :saves
  
  def initialize
    @board = Board.new
    @player = 'w'
    @saves = []
  end

  def game
    intro
    load
    board.show
    loop do
      input
      board.show
      switch_player
      board.player = player
      if board.stalemate?
        board.check? ? checkmate_outro : stalemate_outro
        break
      end
    end
  end

  def input
    board.check? ? check_message : input_intro
    loop do
      pick = gets.chomp.upcase
      next save if pick.upcase == 'SAVE'
      next syntax_error_message unless valid_syntax?(pick)
      pick = [[8-pick[1].to_i, pick[0].ord-65], [8-pick[-1].to_i, pick[-2].ord-65]]
      next move_error_message unless board.valid_move?(pick)
      break
    end
    board.insert
  end

  def switch_player
    player == 'b' ? @player = 'w' : @player = 'b'
  end

  private

  def valid_syntax?(pick)
    pick =~ /^[A-H][1-8]\s[A-H][1-8]$/
  end

  def intro
    puts "\n\n--\u2654--\u2655--\u2656--\u2657--\u2658--\u2659--CHESS--"\
      "\u265F--\u265E--\u265D--\u265C--\u265B--\u265A--\n\n"
    puts "When it's your turn, please insert start and end coordinates\n"\
      "of your preferred move, seperated by a space. E.g. 'B8 C6'.\n"\
      "Insert 'save' when you want to save your game."    
  end

  def checkmate_outro
    winner = { 'w' => 'Black', 'b' => 'White' }
    puts "#Checkmate! #{winner[player]} player won the game."
  end

  def stalemate_outro
    puts "Stalemate! No winner in this game."
  end

  def input_intro
    current_player = { 'w' => 'White', 'b' => 'Black' }
    puts "\n#{current_player[player]} player's turn. Please insert a move."
  end

  def check_message
    current_player = { 'w' => 'White', 'b' => 'Black' }
    puts "\n#{current_player[player]} king is in check. Make your move"\
      " #{current_player[player].downcase} player."
  end

  def syntax_error_message
    puts "Syntax error. Try again."\
      " E.g.: #{('A'..'H').to_a.sample}#{(1..8).to_a.sample}"\
      " #{('A'..'H').to_a.sample}#{(1..8).to_a.sample}"
  end

  def move_error_message
    puts "This move is not allowed. Please try another one."
  end

end