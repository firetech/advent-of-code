require_relative '../../lib/aoc_api'

file = ARGV[0] || AOC.input_file()
#file = 'example1'
#file = 'example1_plus'

@map = {}
@min_x = @max_x = 500
@min_y = @max_y = nil
File.read(file).strip.split("\n").each do |line|
  case line
  when /\A([xy])=(\d+), ([xy])=(\d+)\.\.(\d+)\z/
    a_axis = Regexp.last_match(1)
    a = Regexp.last_match(2).to_i
    b_axis = Regexp.last_match(3)
    b1 = Regexp.last_match(4).to_i
    b2 = Regexp.last_match(5).to_i
    raise "Malformed line: '#{line}'" if a_axis == b_axis
    b1.upto(b2) do |b|
      if a_axis == 'x'
        x, y = a, b
      else
        y, x = a, b
      end
      @min_x = [@min_x, x].compact.min
      @max_x = [@max_x, x].compact.max
      @min_y = [@min_y, y].compact.min
      @max_y = [@max_y, y].compact.max
      @map[[x, y]] = '#'
    end
  else
    raise "Malformed line: '#{line}'"
  end
end

def print_map
  @min_y.upto(@max_y) do |y|
    @min_x.upto(@max_x) do |x|
      print @map[[x, y]] || ' '
    end
    puts
  end
end


FLOORS = ['#', '~']
sources = [[500, @min_y]]
until sources.empty?
  next_sources = []
  sources.each do |x, y|
    next if @map[[x, y]] == '|' # Duplicate source
    if FLOORS.include?(@map[[x, y+1]])
      left = x
      while @map[[left-1, y]] != '#' and FLOORS.include?(@map[[left, y+1]])
        left -= 1
      end
      left_stop = @map[[left-1, y]] == '#'
      right = x
      while @map[[right+1, y]] != '#' and FLOORS.include?(@map[[right, y+1]])
        right += 1
      end
      right_stop = @map[[right+1, y]] == '#'
      if left_stop and right_stop
        state = '~' # Water at rest
        @map[[x, y-1]] = '-' # Filling source (to bypass duplication check)
        next_sources << [x, y-1]
      else
        state = '|' # Flowing water
        next_sources << [left, y+1] unless left_stop
        next_sources << [right, y+1] unless right_stop
      end
      left.upto(right) do |nx|
        @map[[nx, y]] = state
      end
      @min_x = [@min_x, left].min
      @max_x = [@max_x, right].max
    else
      @map[[x, y]] = '|' # Flowing water
      next_sources << [x, y+1]
    end
  end
  sources = next_sources.select { |x, y| y <= @max_y }
  #print_map; gets
end

map_values = @map.values
at_rest = map_values.count('~')
flowing = map_values.count('|')

#print_map

# Part 1
puts "Potentially reachable tiles: #{at_rest + flowing}"

# Part 2
puts "Water tiles at rest: #{at_rest}"

