require_relative '../../lib/aoc'
require_relative '../../lib/priority_queue'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@map = File.read(file).strip.split("\n").map { |line| line.chars.map(&:to_i) }
MAP_HEIGHT = @map.length

# This works for negative coordinates, BUT ONLY if they're only ever used as
# delta values.
# I.e.
#   to_pos(3, 4) + to_pos(-2, -3) == to_pos(1, 1)
# but
#   from_pos(to_pos(-2, -3)) != [-2, -3]
Y_BITS = Math.log2(MAP_HEIGHT*5-1).floor + 1
Y_MASK = (1 << Y_BITS) - 1
def to_pos(x, y)
  return (x << Y_BITS) + y
end
def from_pos(pos)
  return pos >> Y_BITS, pos & Y_MASK
end

DIRS = [
  to_pos(0, -1),
  to_pos(0,  1),
  to_pos(-1, 0),
  to_pos( 1, 0),
]

def dijkstra(map)
  # Copied from 2018/22. ^_^
  tx = map.first.length - 1
  ty = map.length - 1
  target = to_pos(tx, ty)
  x_range = (0..tx)
  y_range = (0..ty)
  start = to_pos(0, 0)
  dist = Hash.new(Float::INFINITY)
  dist[start] = 0
  queue = PriorityQueue.new
  queue.push(start, 0)
  until queue.empty?
    pos = queue.pop_min

    if pos == target
      return dist[target]
    end

    this_dist = dist[pos]
    DIRS.each do |delta|
      npos = pos + delta
      nx, ny = from_pos(npos)
      next unless x_range.include?(nx) and y_range.include?(ny)
      ndist = this_dist + map[ny][nx]
      if ndist < dist[npos]
        dist[npos] = ndist
        queue.push(npos, ndist)
      end
    end
  end
end

# Part 1
puts "Total risk: #{dijkstra(@map)}"

# Part 2
map5 = []
5.times do |y|
  line5 = Array.new(@map.length) { [] }
  5.times do |x|
    @map.each_with_index do |line, yy|
      line5[yy] += line.map { |val| (val - 1 + x + y) % 9 + 1 }
    end
  end
  map5 += line5
end
puts "Total risk for 5x map: #{dijkstra(map5)}"
