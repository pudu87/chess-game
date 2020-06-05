require 'yaml'

module Save

  def load
    show_saves
    puts "\n---Insert file# to LOAD---Or any other key to CONTINUE---"
    file_nr = gets.chomp.to_i
    execute_load(file_nr) if saves.include?(file_nr)
  end

  def show_saves
    print "\nFile list: "
    get_saves
    saves.empty? ? (print "No files available.") : saves.each { |s| print "#{s} "}
    puts
  end

  def get_saves
    saved_files = Dir.entries('./saves').select { |f| !File.directory? f }
    saved_files.each { |s| saves << s.split('.')[0].to_i }
    saves.sort!
  end

  def execute_load(file_nr)
    status = YAML::load(File.read("./saves/#{file_nr}.txt"))
    board.board = status[:board]
    board.history = status[:history]
    board.taken = status[:taken]
    board.player = status[:player]
    @player = status[:player]
  end

  def save
    get_saves
    file_nr = 1
    file_nr += 1 while saves.include?(file_nr)
    status = { board: board.board, history: board.history, 
                taken: board.taken, player: player }
    File.open("./saves/#{file_nr}.txt", 'w') { |f| f.write(YAML::dump(status)) }
    puts "Game saved as '#{file_nr}.txt'---You can continue the current game now:"
  end

end