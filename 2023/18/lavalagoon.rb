require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

DIR2DELTA = {
  'U' => [0, -1],
  'D' => [0,  1],
  'L' => [-1, 0],
  'R' => [ 1, 0]
}
@steps = []
@min_x = 0
@max_x = 0
@min_y = 0
@max_y = 0
x = 0
y = 0
File.read(file).rstrip.split("\n").each do |line|
  case line
  when /\A(U|D|L|R) (\d+) \((\#[0-9a-f]{6})\)\z/
    step = [
      Regexp.last_match(1),
      Regexp.last_match(2).to_i,
      Regexp.last_match(3)
    ]
    @steps << step
    dx, dy = DIR2DELTA[step[0]]
    x += dx * step[1]
    y += dy * step[1]
    @min_x = x if x < @min_x
    @max_x = x if x > @max_x
    @min_y = y if y < @min_y
    @max_y = y if y > @max_y
  else
    raise "Malformed line: '#{line}'"
  end
end

@width = @max_x - @min_x + 1
@height = @max_y - @min_y + 1
@map = Array.new(@height) { Array.new(@width, false) }
x = -@min_x
y = -@min_y
@map[y][x] = true
dug = 1
@steps.each do |dir, count, color|
  dx, dy = DIR2DELTA[dir]
  count.times do
    x += dx
    y += dy
    dug += 1 unless @map[y][x]
    @map[y][x] = true
  end
end

fill_x = -@min_x + 1
fill_y = -@min_y + 1
raise 'Need to be more clever' if not @map[fill_y][fill_x - 1] or @map[fill_y][fill_x]
queue = [[fill_x, fill_y]]
@map[fill_y][fill_x] = true
filled = 1
until queue.empty?
  x, y = queue.shift
  DIR2DELTA.values.each do |dx, dy|
    nx = x + dx
    ny = y + dy
    next if @map[ny][nx]
    @map[ny][nx] = true
    filled += 1
    queue << [nx, ny]
  end
end
puts "Cubic meters of lava in lagoon: #{dug + filled}"
