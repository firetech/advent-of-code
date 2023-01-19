require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@map = {}
File.read(file).rstrip.split("\n").each do |line|
  case line
  when /\AValve (.*) has flow rate=(\d+); tunnels? leads? to valves? ((?:.*(?:, |\z))+)/
    @map[Regexp.last_match(1)] = {
      flow:    Regexp.last_match(2).to_i,
      tunnels: Regexp.last_match(3).split(', ')
    }
  else
    raise "Malformed line: '#{line}'"
  end
end

@flow = @map.transform_values { |v| v[:flow] }

@bit = {}
@map.keys.select { |v| @flow[v] > 0 }.sort.each_with_index do |v, i|
  @bit[v] = 1 << i
end

@move = {}
@map.each_key do |valve|
  queue = [valve]
  dist = { valve => 1 }
  until queue.empty?
    pos = queue.shift
    this_dist = dist[pos]
    @map[pos][:tunnels].each do |new_pos|
      next if dist.has_key?(new_pos)
      dist[new_pos] = this_dist + 1
      queue << new_pos
    end
  end
  @move[valve] = dist.select { |v, _| @flow[v] > 0 }
end

def visit(time = 30, pos = 'AA', open = 0, flow = 0, max = Hash.new(0))
  max[open] = flow if flow > max[open]
  @move[pos].each do |new_pos, cost|
    b = @bit[new_pos]
    next if open & b != 0
    new_time = time - cost
    next if new_time < 0
    visit(new_time, new_pos, open | b, flow + new_time * @flow[new_pos], max)
  end
  return max
end

# Part 1
puts "Most pressure released: #{visit.values.max}"

# Part 2
visited2 = visit(26).sort_by(&:last)
max = visited2.first.last
val = 0
until (o1, v1 = visited2.pop).nil?
  break if v1 + max < val
  visited2.reverse_each do |o2, v2|
    next if o1 & o2 != 0
    sum = v1 + v2
    break if sum < val
    val = sum
  end
end
puts "Most pressure released with elephant: #{val}"
