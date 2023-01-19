require 'set'
require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'
#file = 'example2'

DIRS = {
  'N' => Complex(0, -1),
  'E' => Complex(1, 0),
  'W' => Complex(-1, 0),
  'S' => Complex(0, 1)
}

FAR_ROOM_LIMIT = 1000

branches = []
current = Complex(0, 0)
@doors_from_start = { current => 0 }
File.read(file).strip.each_char do |c|
  case c
  when '^', '$'
    # Ignore
  when 'N', 'E', 'W', 'S'
    new = current + DIRS[c]
    unless @doors_from_start.has_key?(new)
      @doors_from_start[new] = @doors_from_start[current] + 1
    end
    current = new
  when '('
    branches << current
  when '|'
    current = branches.last
  when ')'
    current = branches.pop
  else
    raise "Unexpected character '#{c}'"
  end
end

# Part 1
puts "Most doors passed in shortest path: #{@doors_from_start.values.max}"

# Part 2
far_rooms = @doors_from_start.count { |_, doors| doors >= FAR_ROOM_LIMIT }
puts "Rooms with #{FAR_ROOM_LIMIT} or more doors in shortest path: #{far_rooms}"
