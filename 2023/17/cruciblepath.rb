require_relative '../../lib/aoc'
require_relative '../../lib/priority_queue'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@map = File.read(file).rstrip.split("\n").map do |line|
  line.each_char.map(&:to_i)
end

@y_bits = Math.log2(@map.length).ceil
@y_mask = (1 << @y_bits) - 1
def to_pos(x, y)
  x << @y_bits | y
end
def from_pos(pos)
  return pos >> @y_bits, pos & @y_mask
end

def to_state(pos, dx, dy)
  pos << 4 | (dx+1) << 2 | (dy+1)
end
def from_state(state)
  return state >> 4, ((state >> 2) & 0b11) - 1, (state & 0b11) - 1
end

@target_x = @map.first.length - 1
@target_y = @map.length - 1
@target = to_pos(@target_x, @target_y)

# Dijkstra-ish
def path(max_steps, min_steps = 1)
  start = to_pos(0, 0)
  queue = PriorityQueue.new
  min_dist = Hash.new(Float::INFINITY)
  [to_state(start, 1, 0), to_state(start, 0, 1)].each do |state|
    min_dist[state] = 0
    queue.push(state, 0)
  end
  until queue.empty?
    state = queue.pop_min
    pos, dx, dy = from_state(state)

    return min_dist[state] if pos == @target

    # Walk min_steps..max_steps in perpendicular directions.
    [[-dy, -dx], [dy, dx]].each do |ndx, ndy|
      nx, ny = from_pos(pos)
      ndist = min_dist[state]
      1.upto(max_steps) do |steps|
        nx += ndx
        break if nx < 0 or nx > @target_x
        ny += ndy
        break if ny < 0 or ny > @target_y
        ndist += @map[ny][nx]
        next if steps < min_steps
        nstate = to_state(to_pos(nx, ny), ndx, ndy)
        if ndist < min_dist[nstate]
          min_dist[nstate] = ndist
          queue.push(nstate, ndist)
        end
      end
    end
  end
end

# Part 1
puts "Minimum heat loss: #{path(3)}"

# Part 2
puts "Minimum heat loss (ultra crucibles): #{path(10, 4)}"
