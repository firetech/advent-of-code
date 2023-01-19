require_relative '../../lib/aoc'

@input = (ARGV[0] || AOC.input()).to_i
@target = (ARGV[1] || '31,39').strip.split(',').map(&:to_i)

#@input = 10; @target = [7, 4]

def is_wall?(x, y)
  n = x*x + 3*x + 2*x*y + y + y*y + @input
  # Curiously enough, this seems to be the fastest method in Ruby to count set bits...
  return (n.to_s(2).count('1') % 2 == 1)
end

queue = [[1, 1, 0]]
distance = { [1, 1].hash => 0 }
tkey = @target.hash
while not queue.empty? and not distance.has_key?(tkey)
  x, y, steps = queue.shift
  [[0, -1], [0, 1], [-1, 0], [1, 0]].each do |dx, dy|
    px, py = x + dx, y + dy
    pkey = [px, py].hash
    if px >= 0 and py >= 0 and not distance.has_key?(pkey)
      if is_wall?(px, py)
        distance[pkey] = nil
      else
        distance[pkey] = steps + 1
        queue << [px, py, steps + 1]
      end
    end
  end
end

# Part 1
puts "Minimum steps to reach #{@target.join(',')}: #{distance[tkey]}"

# Part 2
puts "Number of locations reachable in 50 steps or less: #{distance.count{ |_, val| (not val.nil? and val <= 50) }}"
