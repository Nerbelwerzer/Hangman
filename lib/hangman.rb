

class Welcome
  @@films = File.readlines 'hangmanfilms.txt'
  @@dictionary = File.readlines '5desk.txt'

  def self.run
    puts "\n\nWelcome to Hangman! To start a new game, enter your name below. To load a saved game, enter 'load'.\n\n---You can save or load a game at any time by entering 'save' or 'load'---"
    choice = gets.chomp.capitalize
    if choice == 'Load'
      load
    else
      new_game(choice)
    end
  end

  def self.load
    if File.exist?('save_game')
      puts 'Saved game loaded'.green
      File.open('save_game') do |f|
        game = Marshal.load(f)
        game.start_game
      end
    else
      puts "\n\nNo save file found\n\n".red
      run
    end
  end

  def self.new_game(choice)
    player = Player.new(choice)

    puts "\n\nGreetings, #{player.name.bold}. Choose a topic.\n1: Dictionary\n2: Films"

    choice = gets.chomp

    if choice == '1' || choice.start_with?('dict'.downcase)
      word = @@dictionary.sample.chomp
    elsif choice == '2' || choice.start_with?('film'.downcase)
      word = @@films.sample.chomp
    else exit
    end

    game = Game.new(word, player)

    game.start_game
  end
end

class Game
  attr_accessor :word, :board, :wrong_guesses, :player
  def initialize(word, player)
    @word = word.upcase.split('')
    @gallows = ["_______\n| /  |\n|/\n|\n|\n|\n______\n\n",
                "_______\n| /  |\n|/   O\n|\n|\n|\n______\n\n",
                "_______\n| /  |\n|/   O\n|    |\n|\n|\n______\n\n",
                "_______\n| /  |\n|/   O\n|   /|\n|\n|\n______\n\n",
                "_______\n| /  |\n|/   O\n|   /|\\\n|\n|\n______\n\n",
                "_______\n| /  |\n|/   O\n|   /|\\\n|   /\n|\n______\n\n",
                "_______\n| /  |\n|/   " + 'O'.red + "\n|   /|\\\n|   / \\ \n|\n______\n\n",
                "\n_______\n| /  |\n|/\n|       O/\n|      /|\n|      / \\\n______\n\n"]
    @board = ['_ '] * word.length
    @wrong_guesses = []
    @player = player
  end

  def start_game
    replace_spaces
    user_input
  end

  def replace_spaces
    @word.map { |letter| letter.gsub!(' ', '/') }
    spaces_index = @word.each_index.select { |i| @word[i] == '/' }
    spaces_index.each { |i| @board[i] = '/' }
  end

  def print_board
    puts @gallows[@player.lives]
    puts "Spent letters: #{@wrong_guesses.join(', ').red}"
    puts @board.join
  end

  def user_input
    print_board
    puts "\n Choose a letter, #{@player.name}:"
    @letter = gets.chomp.upcase
    validate_guess(@letter)
  end

  def validate_guess(_letter)
    if @letter.downcase == 'save'
      save_game
    elsif @letter.downcase == 'load'
      load_game
    elsif [*'A'..'Z'].include?(@letter.upcase) && @letter.length == 1
      assess_guess
    else
      puts "\n\nInvalid guess".red
      user_input
    end
  end

  def invalid_guess
    puts 'That was not a valid letter. Try again.'
    user_input
  end

  def assess_guess
    if @board.include?(@letter) || @wrong_guesses.include?(@letter)
      puts "\n\nLetter already taken".red
    elsif @word.include?(@letter)
      update_board
    else
      @wrong_guesses << @letter
      @player.lives += 1
    end

    game_over if @player.dead?

    game_win if @board.join == @word.join

    user_input
  end

  def update_board
    @correct_index = @word.each_index.select { |i| @word[i] == @letter }
    @correct_index.each { |i| @board[i] = @letter }
  end

  def game_win
    puts "\n\n\nCongratulations, #{@player.name}!\n\n".green.bold + @word.join.upcase.gsub('/', ' ') + @gallows[7]
    exit
  end

  def game_over
    puts "\n\n\nGame over.".red.bold
    puts @gallows[6] + "\n"
    puts 'Reveal answer? Y/N'
    response = gets.chomp

    if response.upcase == 'Y'
      puts @word.join.upcase.gsub('/', ' ')
      exit
    else exit
    end
  end

  def save_game
    File.open('save_game', 'w') { |f| Marshal.dump(self, f) }
    puts "\n\nGame saved".green
    user_input
  end

  def load_game
    if File.exist?('save_game')
      Welcome.load
    else
      puts 'No save file found'.red
      user_input
    end
  end
end

class Player
  attr_accessor :lives, :name, :dead
  def initialize(name)
    @name = name
    @lives = 0
  end

  def dead?
    return true if @lives == 6
  end
end

class String
  def green
    "\e[32m#{self}\e[0m"
  end

  def red
    "\e[31m#{self}\e[0m"
  end

  def bold
    "\e[1m#{self}\e[22m"
  end
end

Welcome.run
