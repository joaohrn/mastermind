module Roles
  ROLES = ['codebreaker', 'codewriter'].freeze
  VALID_INPUT = [1, 2, 3, 4, 5, 6].freeze
end

class PersonPlayer
  include Roles
  def initialize(option)
    @role = Roles::ROLES[option - 1]
  end
  attr_reader :role

  def create_code
    @code = []
    while @code.length < 4
      puts 'Write a number between 1 and 6'
      new_number = gets.chomp.to_i
      if Roles::VALID_INPUT.include?(new_number)
        @code << new_number
      else
        puts 'invalid input, must be a number between 1 and 6' 
      end
    end
    @code
  end
end

class ComputerPlayer
  include Roles
  def initialize(option)
    @role = Roles::ROLES[option - 1]
    @possible_solutions = []
    Roles::VALID_INPUT.each do |a|
      Roles::VALID_INPUT.each do |b|
        Roles::VALID_INPUT.each do |c|
          Roles::VALID_INPUT.each do |d|
            @possible_solutions << [a, b, c, d]
          end
        end
      end
    end
  end

  def create_code
    @code = []
    4.times do
      @code << Roles::VALID_INPUT.sample
    end
    @code
  end

  def create_guess
    if @possible_solutions.length == 1
      @possible_solutions[0]
    end
    @possible_solutions[Random.rand(@possible_solutions.length - 1)]
  end

  def filter_solutions(previous_guess, correct_numbers, correct_positions)
    arrays_with_correct_numbers = @possible_solutions.select do |possible_solution|
      possible_solution.intersection(previous_guess).length == correct_numbers
    end
    arrays_with_correct_positions = @possible_solutions.select do |possible_solution|
      possible_solution.zip(previous_guess).select { |guess, guessed_number| guess == guessed_number}
                      .length == correct_positions
    end
    @possible_solutions = arrays_with_correct_numbers.intersection(arrays_with_correct_positions)
  end
end

class Mastermind
  VALID_INPUT = [1, 2, 3, 4, 5, 6].freeze
  def initialize
    @game_won = false
  end

  def create_code(code_master)
    code_master.create_code
  end

  def evaluate_guess(guess_array)
    correct_numbers = 0
    correct_positions = 0
    temporary_code = @code.map { |number| number }
    guess_array.each_with_index do |guess, position|
      if @code[position] == guess
        correct_positions += 1
      end
      if temporary_code.include? guess
        correct_numbers += 1
        temporary_code.delete_at(temporary_code.index(guess))
      end
    end
    if correct_positions == 4
      @game_won = true
    end
    [correct_numbers, correct_positions]
  end

  def choose_roles
    loop do
      puts 'Choose your role:'
      puts '1.codebreaker'
      puts '2.codewriter'
      choice = gets.chomp.to_i
      if (1..2).include? choice
        @person_player = PersonPlayer.new choice
        @computer_player = ComputerPlayer.new(choice - 1)
        break
      else
        puts 'invalid input, try again'
      end
    end
  end

  def play_as_codebreaker
    @code = @computer_player.create_code
    (1..6).each do |turn|
      guess = Array.new(0)
      puts "turn #{turn}"
      (1..4).each do |number|
        puts "Type your guess for the #{number} number"
        guess << gets.chomp.to_i
      end
      puts "correct numbers: #{evaluate_guess(guess)[0]}, correct positions: #{evaluate_guess(guess)[1]}"
      puts guess
      if @game_won
        puts 'codebreaker wins!'
        break
      end
    end
    puts "Codewriter wins! #{@code}" unless @game_won
  end

  def play_as_codewriter
    @code = @person_player.create_code
    (1..6).each do |turn|
      guess = @computer_player.create_guess
      @computer_player.filter_solutions(guess, evaluate_guess(guess)[0], evaluate_guess(guess)[1])
      puts "#{guess}correct numbers: #{evaluate_guess(guess)[0]}, correct positions: #{evaluate_guess(guess)[1]}"
      puts 'press enter to continue'
      gets
      if @game_won
        puts 'Codebreaker wins!'
        break
      end
    end
    puts "Codewriter wins! #{@code}" unless @game_won
  end

  def play_game
    choose_roles
    if @person_player.role == 'codewriter'
      play_as_codewriter
    else
      play_as_codebreaker
    end
  end
end

mastermind = Mastermind.new
mastermind.play_game
