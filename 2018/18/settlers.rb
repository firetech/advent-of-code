require_relative '../../lib/aoc_api'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

CHECKS = [10, 1000000000] # Part 1, Part 2
initial_map = File.read(file).strip.split("\n").map { |line| line.chars }

def print_state(map, min)
  #puts map.map { |line| line.join }.join("\n")
  flat_map = map.flatten
  resource = flat_map.count('|') * flat_map.count('#')
  puts "Resource value after #{min} minutes: #{resource}"
end

@maps = { 0 => initial_map }
@seen = {}
hash = nil
1.upto(CHECKS.max) do |min|
  last_map = @maps[min-1]
  map = last_map.map.with_index do |line, y|
    line.map.with_index do |acre, x|
      neighbours = Hash.new(0)
      (-1..1).each do |delta_y|
        (-1..1).each do |delta_x|
          next if delta_x == 0 and delta_y == 0
          nx = x + delta_x
          next if nx < 0 or nx >= line.length
          ny = y + delta_y
          next if ny < 0 or ny >= last_map.length
          neighbours[last_map[ny][nx]] += 1
        end
      end
      state = last_map[y][x]
      case state
      when '.'
        # An open acre will become filled with trees if three or more adjacent
        # acres contained trees. Otherwise, nothing happens.
        state = '|' if neighbours['|'] >= 3
      when '|'
        # An acre filled with trees will become a lumberyard if three or more
        # adjacent acres were lumberyards. Otherwise, nothing happens.
        state = '#' if neighbours['#'] >= 3
      when '#'
        # An acre containing a lumberyard will remain a lumberyard if it was
        # adjacent to at least one other lumberyard and at least one acre
        # containing trees. Otherwise, it becomes open.
        state = '.' if neighbours['#'] < 1 or neighbours['|'] < 1
      else
        raise "Unknown state: #{state.inspect}"
      end
      state
    end
  end
  @maps[min] = map

  if CHECKS.include?(min)
    print_state(map, min)
  end
  hash = map.hash
  if @seen.has_key?(hash)
    # We've reached a repeating state.
    break
  else
    @seen[hash] = min
  end
end

last_min = @maps.keys.last
cycle_start = @seen[hash]
cycle_length = last_min - cycle_start
CHECKS.each do |min|
  next if min <= last_min
  print_state(@maps[cycle_start + (min - cycle_start) % cycle_length], min)
end
