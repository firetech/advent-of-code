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
@blizzards = { 0 => {} }
map.each_with_index do |line, y|
  line.each_with_index do |char, x|
    case char
    when *BLIZZARD_DELTA.keys
      @blizzards[0][to_pos(x, y + 1)] = [BLIZZARD_DELTA[char]]
    when '.'
      # Ignore
    when '#'
      @walls[to_pos(x, y + 1)] = true
    else
      raise "Unexpected character: '#{char}'"
    end
  end
end
@blizzard_cycle = @width.lcm(@height)

start_x = map.first.index('.')
@start = to_pos(start_x, 1)
@walls[to_pos(start_x, 0)] = true # This wall offsets all y with +1
goal_x = map.last.index('.')
goal_y = map.length
@goal = to_pos(goal_x, goal_y)
@walls[to_pos(goal_x, goal_y + 1)] = true

MOVES = [[0, 0], *BLIZZARD_DELTA.values]

queue = [[@start, 0]]
visited = {}
time = 0
trip = 1
goals = [@goal, @start, @goal]
goal = goals.shift
until queue.empty?
  exp_pos, time = queue.shift

  if exp_pos == goal
    puts "Done with trip #{trip} in #{time} minutes"
    visited.clear
    queue.clear
    goal = goals.shift
    trip += 1
    break if goal.nil?
  end

  new_time = time + 1

  blizzards = @blizzards[new_time % @blizzard_cycle]
  if blizzards.nil?
    # Move blizzards
    blizzards = {}
    @blizzards[time].each do |pos, deltas|
      x, y = from_pos(pos)
      deltas.each do |dx, dy|
        nx = x + dx
        ny = y + dy
        new_pos = to_pos(nx, ny)
        if @walls.has_key?(new_pos)
          new_pos = to_pos(nx - dx * @width, ny - dy * @height)
        end
        blizzards[new_pos] ||= []
        blizzards[new_pos] << [dx, dy]
      end
    end
    @blizzards[new_time % @blizzard_cycle] = blizzards
  end

  # Move expedition
  x, y = from_pos(exp_pos)
  MOVES.each do |dx, dy|
    new_pos = to_pos(x + dx, y + dy)
    next if blizzards.has_key?(new_pos) or @walls.has_key?(new_pos)
    visited[new_time] ||= Hash.new(false)
    next if visited[new_time].has_key?(new_pos)
    visited[new_time][new_pos] = true
    queue << [new_pos, new_time]
  end
end
