file = 'input'; part2_days = 100
#file = 'example1'; part2_days = 10

input = File.read(file).strip.split("\n")

# Part 1
def neighbour(x, y, z, dir)
  if not x + y + z == 0
    raise "#{x} + #{y} + #{z} != 0"
  end
  # For explanation, see https://www.redblobgames.com/grids/hexagons/#coordinates-cube
  case dir
  when 'e'
    x += 1
    y -= 1
  when 'ne'
    x += 1
    z -= 1
  when 'nw'
    y += 1
    z -= 1
  when 'w'
    x -= 1
    y += 1
  when 'sw'
    x -= 1
    z += 1
  when 'se'
    y -= 1
    z += 1
  else
    raise "Unknown dir: '#{dir}'"
  end
  return x, y, z
end

grid = Hash.new(false)
input.each do |line|
  x = 0
  y = 0
  z = 0
  line.scan(/(?:(?:n|s)?(?:e|w))/) do |dir|
    x, y, z = neighbour(x, y, z, dir)
  end
  grid[[x, y, z]] = (not grid[[x, y, z]])
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
    x, y, z = state[key][0]
    ndirs.each do |dir|
      npos = neighbour(x, y, z, dir)
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
