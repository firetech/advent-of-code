require_relative '../../lib/aoc_api'
require_relative '../../lib/priority_queue'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@map = File.read(file).strip.split("\n").map { |line| line.chars.map(&:to_i) }

def dijkstra(map)
  # Copied from 2018/22. ^_^
  target = Complex(map.first.length - 1, map.length - 1)
  x_range = (0..target.real)
  y_range = (0..target.imag)
  start = Complex(0, 0)
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
    [ -1i, 1i, -1, 1 ].each do |delta|
      npos = pos + delta
      next unless x_range.include?(npos.real) and y_range.include?(npos.imag)
      ndist = this_dist + map[npos.imag][npos.real]
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
