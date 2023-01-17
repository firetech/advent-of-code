require_relative '../../lib/aoc_api'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

input = File.read(file).strip.split("\n").map(&:chars)
counts = Array.new(input.first.length) { Hash.new(0) }
input.each do |line|
  line.each_with_index do |c, i|
    counts[i][c] += 1
  end
end

# Part 1
code = counts.map { |list| list.max_by { |c, n| n }.first }.join
puts "Code (most common): #{code}"

# Part 2
code = counts.map { |list| list.min_by { |c, n| n }.first }.join
puts "Code (least common): #{code}"
