require 'set'
require_relative '../../lib/aoc_api'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@map = File.read(file).rstrip.split("\n").map { |line| line.chars.map(&:to_i) }

# Part 1
@visible = Set[]
@queue = []
@map.first.length.times do |x|
  @visible << [x, 0]
  @visible << [x, @map.length - 1]
  if x > 0 and x < @map.first.length - 1
    @queue << [x, 1, 0, 1, @map.first[x]]
    @queue << [x, @map.length - 2, 0, -1, @map.last[x]]
  end
end
@map.length.times do |y|
  @visible << [0, y]
  @visible << [@map.first.length - 1, y]
  if y > 0 and y < @map.first.length - 1
    @queue << [1, y, 1, 0, @map[y].first]
    @queue << [@map.first.length - 2, y, -1, 0, @map[y].last]
  end
end

until @queue.empty?
  x, y, dx, dy, height = @queue.shift
  next unless (1..(@map.first.length-2)).include?(x)
  next unless (1..(@map.length-2)).include?(y)
  if @map[y][x] > height
    @visible << [x, y]
  end
  @queue << [x+dx, y+dy, dx, dy, [height, @map[y][x]].max]
end

puts "Trees visible from outside the grid: #{@visible.length}"


# Part 2
max_score = 0
@visible.each do |sx, sy|
  height = @map[sy][sx]
  visible = []
  [[-1, 0], [1, 0], [0, -1], [0, 1]].each do |dx, dy|
    x, y = sx, sy
    view_height = 0
    dir_visible = 0
    begin
      x = x + dx
      y = y + dy
      break unless (0...@map.first.length).include?(x)
      break unless (0...@map.length).include?(y)
      dir_visible += 1
    end while @map[y][x] < height
    visible << dir_visible
  end
  score = visible.inject(&:*)
  max_score = score if score > max_score
end

puts "Highest scenic score: #{max_score}"
