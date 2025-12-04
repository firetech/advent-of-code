require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@map = Hash.new(false)
File.read(file).rstrip.split("\n").each_with_index do |line, y|
  line.each_char.with_index do |char, x|
    if char == "@"
      @map[[x, y]] = true
    end
  end
end

NEIGHBOURS = [
  [-1, -1],
  [ 0, -1],
  [ 1, -1],
  [-1,  0],
  # not counting itself
  [ 1,  0],
  [-1,  1],
  [ 0,  1],
  [ 1,  1],
]

def remove_rolls(map)
  count = 0
  new_map = map.filter do |(x, y), _|
    neighbours = NEIGHBOURS.count do |dx, dy|
      map[[x+dx, y+dy]]
    end
    if neighbours < 4
      count += 1
      false  # Remove from new_map
    else
      true  # Keep in new_map
    end
  end
  return new_map, count
end

# Part 1
new_map, count = remove_rolls(@map)
puts "#{count} rolls can be removed initially"

# Part 2
removed = count
begin
  new_map, count = remove_rolls(new_map)
  removed += count
end while count > 0
puts "#{removed} rolls can be removed in total"
