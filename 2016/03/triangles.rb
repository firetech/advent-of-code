require_relative '../../lib/aoc_api'

input = File.read(ARGV[0] || AOC.input_file()).strip.split("\n").map { |line| line.strip.split(/\s+/).map(&:to_i) }

def possible_triangles(input)
  input.count do |lengths|
    a, b, c = lengths.sort
    a + b > c
  end
end

# Part 1
puts "#{possible_triangles(input)} possible triangles (row oriented)"

# Part 2
new_input = input.transpose.map { |col| col.each_slice(3).to_a }.flatten(1)
puts "#{possible_triangles(new_input)} possible triangles (column oriented)"

