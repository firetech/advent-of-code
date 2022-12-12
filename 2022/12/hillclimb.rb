require_relative '../../lib/priority_queue'

file = ARGV[0] || 'input'
#file = 'example1'

@start1 = nil
@start2 = []
@end = nil
@map = File.read(file).strip.split("\n").map.with_index do |line, y|
  chars = line.chars

  if not (x = line.index('S')).nil?
    chars[x] = 'a'
    @start = [x, y]
  end

  as = (0...chars.length).find_all { |x| chars[x] == 'a' }
  @start2.push(*as.map { |x| [x, y] })

  if not (x = line.index('E')).nil?
    chars[x] = 'z'
    @end = [x, y]
  end

  chars
end

@x_bits = Math.log2(@map.first.length - 1).ceil
@x_mask = (1 << @x_bits) - 1
def to_pos(x, y)
  (y << @x_bits) | x
end
def from_pos(pos)
  return (pos & @x_mask), (pos >> @x_bits)
end

def dijkstra(start = @start)
  # Copied from 2018/22 and 2021/15. ^_^
  x_range = (0...@map.first.length)
  y_range = (0...@map.length)
  dist = Hash.new(Float::INFINITY)
  start_pos = to_pos(*start)
  dist[start_pos] = 0
  queue = PriorityQueue.new
  queue.push(start_pos, 0)
  end_pos = to_pos(*@end)
  until queue.empty?
    pos = queue.pop_min

    break if pos == end_pos

    this_dist = dist[pos]
    x, y = from_pos(pos)
    this_height = @map[y][x].ord
    [[-1, 0], [1, 0], [0, -1], [0, 1]].each do |delta_x, delta_y|
      nx = x + delta_x
      next unless x_range.include?(nx)
      ny = y + delta_y
      next unless y_range.include?(ny)
      next unless @map[ny][nx].ord - this_height <= 1
      npos = to_pos(nx, ny)
      ndist = this_dist + 1
      if ndist < dist[npos]
        dist[npos] = ndist
        queue.push(npos, ndist)
      end
    end
  end

  return dist[end_pos]
end

# Part 1
puts "Shortest path from 'S' to 'E': #{dijkstra}"

# Part 2
puts "Shortest path from any 'a' to 'E': #{@start2.map { |s| dijkstra(s) }.min}"
