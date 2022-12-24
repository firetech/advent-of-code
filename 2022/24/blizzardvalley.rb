require 'set'

file = ARGV[0] || 'input'
#file = 'example1'

BLIZZARD_DELTA = {
  '^' => [ 0, -1],
  'v' => [ 0,  1],
  '<' => [-1,  0],
  '>' => [ 1,  0]
}

@map = []
@blizzards = {}
File.read(file).rstrip.split("\n").each_with_index do |line, y|
  map_line = []
  line.each_char.with_index do |char, x|
    case char
    when *BLIZZARD_DELTA.keys
      @blizzards[[x, y]] = [BLIZZARD_DELTA[char]]
      map_line[x] = '.'
    when '.'
      map_line[x] = '.'
    when '#'
      map_line[x] = '#'
    else
      raise "Unexpected character: '#{char}'"
    end
  end
  @map[y] = map_line
end
@width = @map.first.length - 2
@height = @map.length - 2
@start = [@map.first.index('.'), 0]
@goal = [@map.last.index('.'), @map.length - 1]

MOVES = [
  [ 1,  0],
  [ 0,  1],
  [ 0,  0],
  [-1,  0],
  [ 0, -1]
]


positions = Set[@start]
time = 0
trip = 1
goals = [@goal, @start, @goal]
goal = goals.shift
until goal.nil?
  new_blizzards = {}
  @blizzards.each do |(x, y), deltas|
    deltas.each do |dx, dy|
      nx = x + dx
      nx += @width if nx < 1
      nx -= @width if nx > @width
      ny = y + dy
      ny += @height if ny < 1
      ny -= @height if ny > @height
      new_blizzards[[nx, ny]] ||= []
      new_blizzards[[nx, ny]] << [dx, dy]
    end
  end
  @blizzards = new_blizzards

  new_positions = Set[]
  positions.each do |x, y|
    MOVES.each do |dx, dy|
      nx = x + dx
      ny = y + dy
      next if ny < 0 or ny >= @map.length or @map[ny][nx] == '#'
      next if @blizzards.has_key?([nx, ny])
      new_positions << [nx, ny]
    end
  end
  positions = new_positions

  time += 1

  if positions.include?(goal)
    puts "Done with trip #{trip} in #{time} minutes"
    positions = Set[goal]
    goal = goals.shift
    trip += 1
  end
end
