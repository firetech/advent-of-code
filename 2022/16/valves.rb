file = ARGV[0] || 'input'
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

@usable_valves = @map.keys.select { |valve| @map[valve][:flow] > 0 }.sort

@valve_to_valve = {}
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
  @valve_to_valve[valve] = dist.select do |valve, _|
    @usable_valves.include?(valve)
  end
end

def traverse(pos, left, time)
  max_pressure = 0
  left.each do |new_pos|
    cost = @valve_to_valve[pos][new_pos]
    next if cost > time
    new_time = time - cost
    this_pressure = @map[new_pos][:flow] * new_time
    new_left = left - [new_pos]
    # If we can't beat the current max by turning on all remaining valves NOW,
    # there's no need to go further.
    left_pressure = new_left.sum { |valve| @map[valve][:flow] } * new_time
    next if this_pressure + left_pressure < max_pressure
    new_pressure = this_pressure + yield(new_pos, new_left, new_time)
    if new_pressure > max_pressure
      max_pressure = new_pressure
    end
  end
  return max_pressure
end

# Part 1
@cache = {}
def dfs(pos = 'AA', left = @usable_valves, time = 30)
  state = [pos, left, time].hash
  val = @cache[state]
  if val.nil?
    val = traverse(pos, left, time) do |new_pos, new_left, new_time|
      dfs(new_pos, new_left, new_time)
    end
    @cache[state] = val
  end
  return val
end

puts "Most pressure released: #{dfs}"


# Part 2
def dfs2(pos = 'AA', left = @usable_valves, time = 26)
  val = traverse(pos, left, time) do |new_pos, new_left, new_time|
    dfs2(new_pos, new_left, new_time)
  end
  return (other = dfs('AA', left, 26)) > val ? other : val
end

puts
print 'Traversing with elephant.'
t = Thread.new { loop { sleep 1; print '.' } }
begin
  val = dfs2
ensure
  t.kill
  t.join
end
puts ' Done.'
puts "Most pressure released with elephant: #{val}"
