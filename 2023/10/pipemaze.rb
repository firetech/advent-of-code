require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'
#file = 'example2'
#file = 'example3'
#file = 'example4'
#file = 'example5'

DIRS = [[0, -1], [-1, 0], [1, 0], [0, 1]]

# Construct map
start_cell = []
@map = File.read(file).rstrip.split("\n").map.with_index do |line, y|
  line.chars.map.with_index do |char, x|
    case char
    when '|'
      [[0, -1], [0, 1]]
    when '-'
      [[-1, 0], [1, 0]]
    when 'L'
      [[0, -1], [1, 0]]
    when 'J'
      [[0, -1], [-1, 0]]
    when '7'
      [[-1, 0], [0, 1]]
    when 'F'
      [[1, 0], [0, 1]]
    when '.'
      []
    when 'S'
      @start_x = x
      @start_y = y
      start_cell
    else
      raise "Unexpected map char: '#{char}'"
    end
  end
end
# Find start position shape
DIRS.each do |dx1, dy1|
  ((@map[@start_y + dy1] or [])[@start_x + dx1] or []).each do |dx2, dy2|
    if dx1 + dx2 == 0 and dy1 + dy2 == 0
      start_cell << [dx1, dy1]
    end
  end
end

# Part 1
# Traverse loop
@depth = Array.new(@map.length) { Array.new(@map.first.length) }
@depth[@start_y][@start_x] = 0
queue = [ [@start_x, @start_y] ]
max_depth = 0
until queue.empty?
  x, y = queue.shift
  depth = @depth[y][x]
  @map[y][x].each do |dx, dy|
    nx = x + dx
    ny = y + dy
    next unless @depth[ny][nx].nil?
    new_depth = depth + 1
    max_depth = new_depth if new_depth > max_depth
    @depth[ny][nx] = new_depth
    queue << [nx, ny]
  end
end

puts "Farthest from start: #{max_depth}"

# Part 2
# Enlarge map (of the loop only) so we can traverse between adjacent pipes.
# Each cell in the original becomes 3x3 cells in the new map.
#           .#.       ...       .#.
# e.g. J => ##.  F => .##  | => .#.
#           ...       .#.       .#.
@fill_map = Array.new(@map.length * 3) { Array.new(@map.first.length * 3, false) }
@depth.each_with_index do |line, y|
  line.each_with_index do |depth, x|
    next if depth.nil?
    fx = x * 3 + 1
    fy = y * 3 + 1
    @fill_map[fy][fx] = true
    @map[y][x].each do |dx, dy|
      @fill_map[fy + dy][fx + dx] = true
    end
  end
end
# Flood fill outside
# Since only the loop is included in the new map, all edges should be empty, i.e. (0, 0) can reach all the way around.
fill_start = [0, 0]
queue = [fill_start]
until queue.empty?
  pos = queue.shift
  x, y = pos
  DIRS.each do |dx, dy|
    ny = y + dy
    next if ny < 0 or @fill_map[ny].nil?
    nx = x + dx
    next if nx < 0 or @fill_map[ny][nx].nil?
    next if @fill_map[ny][nx]
    @fill_map[ny][nx] = true
    queue << [nx, ny]
  end
end

# Check centerpoints of each 3x3 cell if they're untouched (i.e. and enclosed tile in the original map).
inside = 0
@map.each_index do |y|
  @map.first.each_index do |x|
    inside += 1 unless @fill_map[y * 3 + 1][x * 3 + 1]
  end
end
puts "Tiles enclosed by the loop: #{inside}"
