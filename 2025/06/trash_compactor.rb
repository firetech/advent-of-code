require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@problems = File.read(file).rstrip.split("\n").map { |line| line.strip.split(/\s+/) }.transpose

sum =  @problems.sum(0) do |problem|
  op = problem.last.to_sym
  numbers = problem[0..-2].map(&:to_i)
  numbers.inject(&op)
end

puts "Sum of problems: #{sum}"
