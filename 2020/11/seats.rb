require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

input = File.read(file).strip.split("\n").map do |line|
  line.each_char.map do |char|
    case char
    when 'L'
      false
    when '.'
      nil
    end
  end
end

def get_neighbours(map, x, y, see_past_floor)
  neighbours = 0
  to_check = [[-1, -1], [0, -1], [1, -1], [-1, 0], [1, 0], [-1, 1], [0, 1], [1, 1]]
  while not to_check.empty?
    dx, dy = to_check.shift
    cx = x + dx
    cy = y + dy
    if cx < 0 or cy < 0 or cy >= map.length or cx >= map.first.length
      next
    end
    seat = map[cy][cx]
    if seat
      neighbours += 1
    elsif seat.nil? and see_past_floor
      to_check << [ dx + (dx <=> 0), dy + (dy <=> 0)]
    end
  end
  return neighbours
end

def next_state(map, max_neighbours, see_past_floor)
  map.map.with_index do |line, y|
    line.map.with_index do |seat, x|
      if seat.nil? # floor
        nil
      else
        neighbours = get_neighbours(map, x, y, see_past_floor)
        if seat and neighbours >= max_neighbours
          false
        elsif not seat and neighbours == 0
          true
        else
          seat
        end
      end
    end
  end
end

def stable_state(map, max_neighbours, see_past_floor)
  last_map = nil
  while map != last_map
    last_map = map
    map = next_state(map, max_neighbours, see_past_floor)
  end
  return map.map { |line| line.count(true) }.sum
end

#part 1
puts "Short-sighted stable state: #{stable_state(input, 4, false)}"

#part 2
puts "Full vision stable state: #{stable_state(input, 5, true)}"
