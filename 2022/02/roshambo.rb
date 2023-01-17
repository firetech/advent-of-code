require_relative '../../lib/aoc_api'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@strategy = Hash.new(0)
File.read(file).strip.split("\n").each do |line|
  case line
  when /\A(A|B|C) (X|Y|Z)\z/
    @strategy[line] += 1
  else
    raise "Malformed line: '#{line}'"
  end
end

# Part 1
@score1 = @strategy['A X'] * (1 + 3) + # Rock     <- Rock     => Draw
          @strategy['A Y'] * (2 + 6) + # Rock     <- Paper    => Win
          @strategy['A Z'] * (3 + 0) + # Rock     <- Scissors => Loss
          @strategy['B X'] * (1 + 0) + # Paper    <- Rock     => Loss
          @strategy['B Y'] * (2 + 3) + # Paper    <- Paper    => Draw
          @strategy['B Z'] * (3 + 6) + # Paper    <- Scissors => Win
          @strategy['C X'] * (1 + 6) + # Scissors <- Rock     => Win
          @strategy['C Y'] * (2 + 0) + # Scissors <- Paper    => Loss
          @strategy['C Z'] * (3 + 3)   # Scissors <- Scissors => Draw
puts "XYZ means Rock/Paper/Scissors => score: #{@score1}"

# Part 2
@score2 = @strategy['A X'] * (3 + 0) + # Rock     <- Loss => Scissors
          @strategy['A Y'] * (1 + 3) + # Rock     <- Draw => Rock
          @strategy['A Z'] * (2 + 6) + # Rock     <- Win  => Paper
          @strategy['B X'] * (1 + 0) + # Paper    <- Loss => Rock
          @strategy['B Y'] * (2 + 3) + # Paper    <- Draw => Paper
          @strategy['B Z'] * (3 + 6) + # Paper    <- Win  => Scissors
          @strategy['C X'] * (2 + 0) + # Scissors <- Loss => Paper
          @strategy['C Y'] * (3 + 3) + # Scissors <- Draw => Scissors
          @strategy['C Z'] * (1 + 6)   # Scissors <- Win  => Rock
puts "XYZ means Lose/Draw/Win => score: #{@score2}"
