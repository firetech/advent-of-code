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
    @start = Complex(x, y)
  end
  as = (0...chars.length).find_all { |x| chars[x] == 'a' }
  @start2.push(*as.map { |x| Complex(x, y) })
  if not (x = line.index('E')).nil?
    chars[x] = 'z'
    @end = Complex(x, y)
  end
  chars
end

def dijkstra(start = @start)
  # Copied from 2021/15. ^_^
  x_range = (0...@map.first.length)
  y_range = (0...@map.length)
  dist = Hash.new(Float::INFINITY)
  dist[start] = 0
  queue = PriorityQueue.new
  queue.push(start, 0)
  until queue.empty?
    pos = queue.pop_min

    if pos == @end
      return dist[@end]
    end

    this_dist = dist[pos]
    this_height = @map[pos.imag][pos.real].ord
    [ -1i, 1i, -1, 1 ].each do |delta|
      npos = pos + delta
      next unless x_range.include?(npos.real) and y_range.include?(npos.imag)
      next unless @map[npos.imag][npos.real].ord - this_height <= 1
      ndist = this_dist + 1
      if ndist < dist[npos]
        dist[npos] = ndist
        queue.push(npos, ndist)
      end
    end
  end

  return dist[@end]  # Should be Infinity if we get here
end

# Part 1
puts "Shortest path from 'S' to 'E': #{dijkstra}"

# Part 2
puts "Shortest path from any 'a' to 'E': #{@start2.map { |s| dijkstra(s) }.min}"
