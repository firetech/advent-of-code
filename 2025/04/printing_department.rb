require 'set'
require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@map_input = File.read(file).rstrip.split("\n")

# This works for negative coordinates, BUT ONLY if they're only ever used as
# delta values.
# I.e.
#   to_pos(3, 4) + to_pos(-2, -3) == to_pos(1, 1)
# but
#   from_pos(to_pos(-2, -3)) != [-2, -3]
Y_BITS = Math.log2(@map_input.length).floor + 1
Y_MASK = (1 << Y_BITS) - 1
def to_pos(x, y)
  return (x << Y_BITS) + y
end
def from_pos(pos)
  return pos >> Y_BITS, pos & Y_MASK
end

@map = Set[]
@map_input.each_with_index do |line, y|
  line.each_char.with_index do |char, x|
    if char == "@"
      @map << to_pos(x+1, y+1)
    end
  end
end

NEIGHBOURS = [
  to_pos(-1, -1),
  to_pos( 0, -1),
  to_pos( 1, -1),
  to_pos(-1,  0),
  # not counting itself
  to_pos( 1,  0),
  to_pos(-1,  1),
  to_pos( 0,  1),
  to_pos( 1,  1),
]

def remove_rolls(map, to_check = map)
  count = 0
  new_map = map - to_check
  new_to_check = Set[]
  to_check.each do |pos|
    neighbours = NEIGHBOURS.filter_map do |dpos|
      npos = pos + dpos
      npos if map.include?(npos)
    end
    if neighbours.length < 4
      count += 1
      new_to_check.merge(neighbours)
    else
      new_map << pos
    end
  end
  return count, new_map, new_to_check & new_map
end

# Part 1
count, new_map, to_check = remove_rolls(@map)
puts "#{count} rolls can be removed initially"

# Part 2
removed = count
begin
  count, new_map, to_check = remove_rolls(new_map, to_check)
  removed += count
end while count > 0
puts "#{removed} rolls can be removed in total"
