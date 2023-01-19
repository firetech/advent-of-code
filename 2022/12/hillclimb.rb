require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@start = nil
@starts = []
@end = nil
@map = File.read(file).strip.split("\n").map.with_index do |line, y|
  chars = line.chars

  if not (x = line.index('S')).nil?
    chars[x] = 'a'
    @start = [x, y]
  end

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

def bfs(start, end_at, backwards = false)
  x_range = (0...@map.first.length)
  y_range = (0...@map.length)
  dist = Hash.new(Float::INFINITY)
  start_pos = to_pos(*start)
  dist[start_pos] = 0
  queue = []
  queue << start_pos
  end_pos = nil
  if end_at.is_a?(Array)
    end_pos = to_pos(*end_at)
  end
  until queue.empty?
    pos = queue.shift

    break if pos == end_pos

    this_dist = dist[pos]
    x, y = from_pos(pos)
    height_char = @map[y][x]
    if height_char == end_at
      end_pos = pos
      break
    end

    this_height = height_char.ord
    [[-1, 0], [1, 0], [0, -1], [0, 1]].each do |delta_x, delta_y|
      nx = x + delta_x
      next unless x_range.include?(nx)
      ny = y + delta_y
      next unless y_range.include?(ny)
      height_diff = @map[ny][nx].ord - this_height
      height_diff = -height_diff if backwards
      next unless height_diff <= 1
      npos = to_pos(nx, ny)
      ndist = this_dist + 1
      if ndist < dist[npos]
        dist[npos] = ndist
        queue << npos
      end
    end
  end

  return dist[end_pos]
end

# Part 1
puts "Shortest path from 'S' to 'E': #{bfs(@start, @end)}"

# Part 2
puts "Shortest path from any 'a' to 'E': #{bfs(@end, 'a', true)}"
