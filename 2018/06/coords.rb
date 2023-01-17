require 'set'
require_relative '../../lib/aoc_api'

file = ARGV[0] || AOC.input_file()
part2_dist = (ARGV[1] || 10_000).to_i

#file = 'example1'; part2_dist = 32

@coords = File.read(file).strip.split("\n").map do |line|
  line.split(', ').map(&:to_i)
end

xs = @coords.map(&:first)
min_x, max_x = xs.min-1, xs.max+1
ys = @coords.map(&:last)
min_y, max_y = ys.min-1, ys.max+1

@closest = []
on_edge = Set[]
within_max_dist = 0
min_y.upto(max_y) do |y|
  min_x.upto(max_x) do |x|
    dist = {}
    @coords.each_with_index do |(cx, cy), i|
      dist[i] = (cx - x).abs + (cy - y).abs
    end

    # Part 1
    min_dist = dist.values.min
    closest = dist.select { |i, d| d == min_dist }.keys
    if closest.length == 1
      closest = closest.first
      if [min_x, max_x].include?(x) or [min_y, max_y].include?(y)
        on_edge << closest
      elsif not on_edge.include?(closest)
        @closest << closest
      end
    end

    # Part 2
    if dist.values.sum < part2_dist
      within_max_dist += 1
    end
  end
end

# Part 1
@count = Hash.new(0)
@closest.each do |c|
  next if on_edge.include?(c)
  @count[c] += 1
end

puts "Size of biggest finite area: #{@count.values.max}"

# Part 2
puts "Size of area with total distance < #{part2_dist}: #{within_max_dist}"

