require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

BLIZZARD_DELTA = {
  '^' => [ 0, -1],
  'v' => [ 0,  1],
  '<' => [-1,  0],
  '>' => [ 1,  0]
}

map = File.read(file).rstrip.split("\n").map(&:chars)
@width = map.first.length - 2
@height = map.length - 2

@x_bits = Math.log2(map.first.length - 1).ceil
@x_mask = (1 << @x_bits) - 1
def to_pos(x,y)
  return y << @x_bits | x
end
def from_pos(pos)
  return pos & @x_mask, pos >> @x_bits
end

# y positions are offset by +1 to fit a wall above the start position

@walls = Hash.new(false)
@blizzards = {}
map.each_with_index do |line, y|
  line.each_with_index do |char, x|
    case char
    when *BLIZZARD_DELTA.keys
      @blizzards[to_pos(x, y + 1)] = [BLIZZARD_DELTA[char]]
    when '.'
      # Ignore
    when '#'
      @walls[to_pos(x, y + 1)] = true
    else
      raise "Unexpected character: '#{char}'"
    end
  end
end

start_x = map.first.index('.')
@start = to_pos(start_x, 1)
@walls[to_pos(start_x, 0)] = true # This wall offsets all y with +1
goal_x = map.last.index('.')
goal_y = map.length
@goal = to_pos(goal_x, goal_y)
@walls[to_pos(goal_x, goal_y + 1)] = true

MOVES = [[0, 0], *BLIZZARD_DELTA.values]

positions = [@start]
time = 0
trip = 1
goals = [@goal, @start, @goal]
goal = goals.shift
until goal.nil?
  new_blizzards = {}
  # Move blizzards
  @blizzards.each do |pos, deltas|
    x, y = from_pos(pos)
    deltas.each do |dx, dy|
      nx = x + dx
      ny = y + dy
      new_pos = to_pos(nx, ny)
      if @walls.has_key?(new_pos)
        new_pos = to_pos(nx - dx * @width, ny - dy * @height)
      end
      new_blizzards[new_pos] ||= []
      new_blizzards[new_pos] << [dx, dy]
    end
  end
  @blizzards = new_blizzards

  # Move expedition
  new_positions = Hash.new(false)
  positions.each do |pos|
    x, y = from_pos(pos)
    MOVES.each do |dx, dy|
      new_pos = to_pos(x + dx, y + dy)
      next if @blizzards.has_key?(new_pos) or @walls.has_key?(new_pos)
      new_positions[new_pos] = true
    end
  end
  raise "Ehm?" if new_positions.empty?

  time += 1

  if new_positions.has_key?(goal)
    puts "Done with trip #{trip} in #{time} minutes"
    positions = [goal]
    goal = goals.shift
    trip += 1
  else
    positions = new_positions.keys
  end
end
