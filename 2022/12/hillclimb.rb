require_relative '../../lib/priority_queue'
require_relative '../../lib/multicore'

file = ARGV[0] || 'input'
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

  as = (0...chars.length).find_all { |x| chars[x] == 'a' }
  @starts.push(*as.map { |x| [x, y] })

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

def dijkstra(start)
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

stop = nil
answers = {}
begin
  input, output, stop = Multicore.run do |worker_in, worker_out|
    until (start = worker_in[]).nil?
      worker_out[[start, dijkstra(start)]]
    end
  end
  @starts.each { |start| input << start } # Includes the part 1 start
  input.close
  @starts.length.times do
    start, ans = output.pop
    raise "Worker returned nil" if ans.nil?
    answers[start] = ans
  end
ensure
  stop[] unless stop.nil?
end

# Part 1
puts "Shortest path from 'S' to 'E': #{answers[@start]}"

# Part 2
puts "Shortest path from any 'a' to 'E': #{answers.values.min}"
