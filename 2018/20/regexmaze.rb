require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'
#file = 'example2'

DIRS = {
  'N' => [0, -1],
  'E' => [1, 0],
  'W' => [-1, 0],
  'S' => [0, 1]
}
OPPOSITE = {
  'N' => 'S',
  'E' => 'W',
  'W' => 'E',
  'S' => 'N'
}

FAR_ROOM_LIMIT = 1000

class Room
  attr_reader :x, :y
  def initialize(x, y)
    @x = x
    @y = y
    @doors = {}
  end

  def has_door?(dir)
    @doors.has_key?(dir)
  end

  def doors
    @doors.keys
  end

  def [](dir)
    @doors[dir]
  end

  def []=(dir, room)
    raise "Duplicate door '#{dir}'" unless [nil, room].include?(@doors[dir])
    @doors[dir] = room
  end
end

def print_map
  last_line = nil
  @min_y.upto(@max_y) do |y|
    line1 = ''
    line2 = ''
    line3 = ''
    @min_x.upto(@max_x) do |x|
      room = @map[[x, y]]
      west_edge = [
        "\u2588",
        (room.has_door?('W') ? '|' : "\u2588"),
        "\u2588"
      ]
      if line1.empty?
        line1, line2, line3 = west_edge
      elsif line2[-1,1] != west_edge[1]
        raise "Border mismatch on y=#{x} between x=#{x-1} and x=#{x}"
      end
      line1 << (room.has_door?('N') ? '-' : "\u2588")
      line2 << ((x == 0 and y == 0) ? 'X' : ' ')
      line3 << (room.has_door?('S') ? '-' : "\u2588")
      line1 << "\u2588"
      line2 << (room.has_door?('E') ? '|' : "\u2588")
      line3 << "\u2588"
    end
    if last_line.nil?
      puts line1
    elsif line1 != last_line
      raise "Border mismatch between y=#{y-1} and y=#{y}"
    end
    puts line2
    puts line3
    last_line = line3
  end
end

@start = Room.new(0, 0)
@map = { [@start.x, @start.y] => @start }
@min_x = @max_x = @start.x
@min_y = @max_y = @start.y
@doors_from_start = { @start => 0 }
branches = []
current = @start
File.read(file).strip.each_char do |c|
  case c
  when '^', '$'
    # Ignore
  when 'N', 'E', 'W', 'S'
    delta_x, delta_y = DIRS[c]
    x = current.x + delta_x
    y = current.y + delta_y
    @min_x = x if x < @min_x
    @max_x = x if x > @max_x
    @min_y = y if y < @min_y
    @max_y = y if y > @max_y
    pos = [x, y]
    new = @map[pos]
    if new.nil?
      new = Room.new(x, y)
      @map[pos] = new
      @doors_from_start[new] = @doors_from_start[current] + 1
    end
    current[c] = new
    new[OPPOSITE[c]] = current
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

print_map

# Part 1
puts "Most doors passed in shortest path: #{@doors_from_start.values.max}"

# Part 2
far_rooms = @doors_from_start.count { |_, doors| doors >= FAR_ROOM_LIMIT }
puts "Rooms with #{FAR_ROOM_LIMIT} or more doors in shortest path: #{far_rooms}"
