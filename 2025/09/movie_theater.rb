require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@tiles = File.read(file).rstrip.split("\n").map do |line|
  line.split(',').map(&:to_i)
end

# Part 1
largest_area = 0
@tiles.combination(2) do |(x1, y1), (x2, y2)|
  area = ((x1 - x2).abs + 1) * ((y1 - y2).abs + 1)
  largest_area = area if area > largest_area
end
puts "Largest rectangle area: #{largest_area}"
