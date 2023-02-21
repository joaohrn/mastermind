class Mastermind
  def initialize
    @code = Array.new(4) { |indesx|rand 6 }
  end

  def evaluate_guess(guess_array)
    correct_numbers = 0
    correct_positions = 0
    guess_array.each_with_index do |guess, position|
      if @code[position] == guess
        correct_positions += 1
      elsif @code.any? { |digit| digit == guess }
        correct_numbers += 1
      end
    end
    [correct_numbers, correct_positions]
  end
end