require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

def to_pos(x, y)
  (y << 10) | x
end

@map = {}
@min_x = @max_x = 500
@min_y = @max_y = 0
File.read(file).rstrip.split("\n").each do |line|
  segments = line.split(" -> ")
  raise "Malformed line: '#{line}'" if segments.length < 2
  last_x = nil
  last_y = nil
  segments.each do |segment|
    case segment
    when /\A(\d+),(\d+)\z/
      x = Regexp.last_match(1).to_i
      y = Regexp.last_match(2).to_i
      @min_x = [@min_x, x].min
      @max_x = [@max_x, x].max
      @min_y = [@min_y, y].min
      @max_y = [@max_y, y].max
      unless last_x.nil? or last_y.nil?
        [last_x, x].min.upto([last_x, x].max) do |px|
          [last_y, y].min.upto([last_y, y].max) do |py|
            @map[to_pos(px, py)] = '#'
          end
        end
      end
      last_x = x
      last_y = y
    else
      raise "Malformed segment: '#{segment}'"
    end
  end
end

def get_map(x, y, inf_floor = false)
  if inf_floor and y == @max_y
    return '#'
  end
  return @map[to_pos(x, y)]
end

def print_map(inf_floor = false)
  x_diff = inf_floor ? 2 : 0
  @min_y.upto(@max_y) do |y|
    (@min_x - x_diff).upto(@max_x + x_diff) do |x|
      print get_map(x, y, inf_floor) || ' '
    end
    puts
  end
end

@count = 0
def fill_map(inf_floor = false)
  stack = [ [500, 0] ]
  until stack.empty?
    x, y = stack.pop
    begin
      moved = false
      old_pos = [x, y]
      if get_map(x, y+1, inf_floor).nil?
        y += 1
        moved = true
      elsif get_map(x-1, y+1, inf_floor).nil?
        x -= 1
        y += 1
        moved = true
      elsif get_map(x+1, y+1, inf_floor).nil?
        x += 1
        y += 1
        moved = true
      end
      stack << old_pos if moved
    end while moved and y < @max_y
    break if y >= @max_y
    @min_x = [@min_x, x].min
    @max_x = [@max_x, x].max
    @map[to_pos(x, y)] = 'o'
    @count += 1
  end
  return @count
end

# Part 1
count1 = fill_map
#print_map
puts "Units of sand filled before abyss: #{count1}"

# Part 2
@max_y += 2
count2 = fill_map(true)
#print_map(true)
puts "Units of sand to fill cave: #{count2}"
