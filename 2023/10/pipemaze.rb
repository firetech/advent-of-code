require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'
#file = 'example2'
#file = 'example3'
#file = 'example4'
#file = 'example5'

@start = nil
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
      @start = [x, y]
      :start
    else
      raise "Unexpected map char: '#{char}'"
    end
  end
end

DIRS = [[0, -1], [-1, 0], [1, 0], [0, 1]]

# Find start position shape
sx, sy = @start
start_shape = []
DIRS.each do |dx1, dy1|
  ((@map[sy + dy1] or [])[sx + dx1] or []).each do |dx2, dy2|
    if dx1 + dx2 == 0 and dy1 + dy2 == 0
      start_shape << [dx1, dy1]
    end
  end
end
@map[sy][sx] = start_shape

# Part 1
# Traverse loop
@depth = { @start => 0 }
queue = [ @start ]
until queue.empty?
  pos = queue.shift
  x, y = pos
  depth = @depth[pos]
  @map[y][x].each do |dx, dy|
    new_pos = [x + dx, y + dy]
    next if @depth.has_key?(new_pos)
    @depth[new_pos] = depth + 1
    queue << new_pos
  end
end

puts "Farthest from start: #{@depth.values.max}"

# Part 2
# Enlarge map (of the loop only) so we can traverse between adjacent pipes.
@fill_map = Array.new(@map.length * 3) { Array.new(@map.first.length * 3, false) }
@depth.each_key do |x, y|
  fx = x * 3 + 1
  fy = y * 3 + 1
  @fill_map[fy][fx] = true
  @map[y][x].each do |dx, dy|
    @fill_map[fy + dy][fx + dx] = true
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

inside = 0
@map.each_index do |y|
  @map.first.each_index do |x|
    inside += 1 unless @fill_map[y * 3 + 1][x * 3 + 1]
  end
end
puts "Tiles enclosed by the loop: #{inside}"
