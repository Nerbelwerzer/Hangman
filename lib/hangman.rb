class Board
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
    validate_guess?(@letter) ? assess_guess : invalid_guess
    user_input
  end

  def validate_guess?(_letter)
    return true if [*'A'..'Z'].include?(@letter.upcase) && @letter.length == 1
  end

  def invalid_guess
    print_board
    puts 'That was not a valid letter. Try again.'
    user_input
  end

  def assess_guess
    if @word.include?(@letter)
      update_board
    elsif @board.include?(@letter) || @wrong_guesses.include?(@letter)
      puts 'Letter already taken'
    else
      @wrong_guesses << @letter
      @player.lives += 1
      puts @player.lives
    end

    game_over if @player.dead?

    game_win if @board.join == @word.join
  end

  def game_win
    puts "\n\n\nCongratulations, #{@player.name}!\n\n".green.bold + @word.join.capitalize.gsub('/', ' ') + @gallows[7]
    exit
  end

  def game_over
    puts "\n\n\nGame over.".red.bold
    puts @gallows[6] + "\n\n\n"
    puts 'Reveal answer? Y/N'
    response = gets.chomp

    if response.upcase == 'Y'
      puts @word.join.capitalise.gsub('/', ' ')
      exit
    else exit
    end
  end

  def update_board
    @correct_index = @word.each_index.select { |i| @word[i] == @letter }
    @correct_index.each { |i| @board[i] = @letter }
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

films = File.readlines 'movies.txt'
dictionary = File.readlines '5desk.txt'

puts 'Welcome to Hangman. Please enter your name:'
player = Player.new(gets.chomp.capitalize)

puts "\n\nChoose a topic\n1: Dictionary\n2: Films"
choice = gets.chomp

if choice == '1'
  word = dictionary.sample.chomp
elsif choice == '2'
  word = films.sample.chomp
else exit
end

game = Board.new(word, player)

game.start_game
