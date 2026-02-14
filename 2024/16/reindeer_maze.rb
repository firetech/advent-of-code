require 'set'
require_relative '../../lib/aoc'
require_relative '../../lib/priority_queue'

file = ARGV[0] || AOC.input_file()
#file = 'example1'
#file = 'example2'

map_lines = File.read(file).rstrip.split("\n")
MAP_HEIGHT = map_lines.count
MAP_WIDTH = map_lines.first.length

# This works for negative coordinates, BUT ONLY if they're only ever used as
# delta values.
# I.e.
#   to_pos(3, 4) + to_pos(-2, -3) == to_pos(1, 1)
# but
#   from_pos(to_pos(-2, -3)) != [-2, -3]
X_BITS = Math.log2(MAP_WIDTH - 1).floor + 1
def to_pos(x, y)
  return (y << X_BITS) + x
end

DIRS = [
  to_pos( 1,  0),
  to_pos( 0,  1),
  to_pos(-1,  0),
  to_pos( 0, -1)
]

def to_state(pos, dir)
  return pos << 2 | dir
end
def from_state(state)
  return state >> 2, state & 0b11
end

@walls = Set[]
@start = nil
@end = nil
map_lines.each_with_index do |line, y|
  line.each_char.with_index do |char, x|
    pos = to_pos(x, y)
    case char
    when '#'
      @walls << pos
    when 'S'
      raise 'Ehm?' unless @start.nil?
      @start = pos
    when 'E'
      raise 'Ehm?' unless @end.nil?
      @end = pos
    when '.'
      # Do nothing
    else
      raise "Unexpected map character: '#{char}'"
    end
  end
end

start = to_state(@start, 0)
cost = Hash.new(Float::INFINITY)
cost[start] = 0
path = {}
path[start] = [@start]
@best_cost = nil
@best_tiles = nil
queue = PriorityQueue.new
queue.push(start, 0)
until queue.empty?
  state = queue.pop
  pos, dir = from_state(state)
  this_cost = cost[state]
  this_path = path[state]

  if pos == @end
    @best_cost = this_cost
    @best_tiles = this_path.uniq.length
    break
  end

  [
    [pos + DIRS[dir], dir, this_cost + 1],
    [pos, (dir + 1) % 4, this_cost + 1000],
    [pos, (dir - 1) % 4, this_cost + 1000]
  ].each do |npos, ndir, ncost|
    next if @walls.include?(npos)
    nstate = to_state(npos, ndir)
    current_cost = cost[nstate]
    if ncost < current_cost
      cost[nstate] = ncost
      path[nstate] = this_path + [npos]
      queue.push(nstate, ncost)
    elsif ncost == current_cost
      path[nstate] += this_path
    end
  end
end

# Part 1
puts "Lowest possible score: #{@best_cost}"

# Part 2
puts "Tiles included in at least one best path: #{@best_tiles}"
