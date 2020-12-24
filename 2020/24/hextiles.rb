file = 'input'; part2_days = 100
#file = 'example1'; part2_days = 10

input = File.read(file).strip.split("\n")

# Part 1
def neighbour(q, r, dir)
  # For explanation, see https://www.redblobgames.com/grids/hexagons/#coordinates-axial
  case dir
  when 'e'
    q += 1
  when 'ne'
    q += 1
    r -= 1
  when 'nw'
    r -= 1
  when 'w'
    q -= 1
  when 'sw'
    q -= 1
    r += 1
  when 'se'
    r += 1
  else
    raise "Unknown dir: '#{dir}'"
  end
  return q, r
end

grid = Hash.new(false)
input.each do |line|
  pos = [0, 0]
  line.scan(/(?:(?:n|s)?(?:e|w))/) do |dir|
    pos = neighbour(*pos, dir)
  end
  grid[pos] = (not grid[pos])
end
puts "#{grid.values.count(true)} black tiles generated"


# Part 2
# This implementation is quite similar to day 17...
state = {}
grid.each do |pos, value|
  next if not value
  state[pos.hash] = [pos, true, 0]
end
ndirs = ['e', 'ne', 'nw', 'w', 'sw', 'se']
part2_days.times do
  state.keys.each do |key| # Not using each_key due to modification
    q, r = state[key][0]
    ndirs.each do |dir|
      npos = neighbour(q, r, dir)
      key = npos.hash
      nstate = state[key]
      if nstate.nil?
        state[key] = [npos, false, 1]
      else
        nstate[2] += 1
      end
    end
  end
  new_state = {}
  state.each_value do |pos, active, neighbours|
    if (active and (neighbours == 1 or neighbours == 2)) or (not active and neighbours == 2)
      new_state[pos.hash] = [pos, true, 0]
    end
  end
  state = new_state
end
puts "#{state.count} black tiles after #{part2_days} days"
