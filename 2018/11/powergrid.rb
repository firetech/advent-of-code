require_relative '../../lib/aoc_api'

@serial = (ARGV[0] || File.read(AOC.input_file()).strip).to_i
#@serial = 8
#@serial = 18
#@serial = 42

def level(x, y)
  rack = (x+1) + 10
  level = (rack * (y+1) + @serial) * rack
  return (level % 1000) / 100 - 5
end

GRID_SIZE = 300

@grid = Array.new(GRID_SIZE) { |y| Array.new(GRID_SIZE) { |x| level(x, y) } }

# https://en.wikipedia.org/wiki/Summed-area_table
@sumarea = [ Array.new(GRID_SIZE+1, 0) ]
@grid.each_with_index do |grid_line, y|
  prev_line = @sumarea.last
  last_val = 0
  @sumarea << [0] + grid_line.map.with_index do |val, x|
    last_val = val + last_val + prev_line[x+1] - prev_line[x]
  end
end

def max_power(sizes)
  if not sizes.respond_to? :each
    sizes = [ sizes ]
  end
  pos = nil
  maxlevel = 0
  pos_without_size = true
  sizes.each do |size|
    if not pos.nil?
      pos_without_size = false
    end
    0.upto(GRID_SIZE - size) do |y|
      0.upto(GRID_SIZE - size) do |x|
        level =   @sumarea[y][x]      - @sumarea[y][x+size] \
                - @sumarea[y+size][x] + @sumarea[y+size][x+size]
        if level > maxlevel
          maxlevel = level
          pos = [x+1, y+1, size]
        end
      end
    end
  end
  if pos_without_size
    pos.pop
  end
  return pos, maxlevel
end

# Part 1
pos, power = max_power(3)
puts "Coordinate of largest 3x3 power square: #{pos.join(',')}"

# Part 2
min_size = 1
# Skip sizes that are physically unable to trump the 3x3 power
while (4 * (min_size+1)**2) < power or min_size < 3
  min_size += 1
end
pos, power = max_power(min_size..GRID_SIZE)
puts "Identifier of largest power square: #{pos.join(',')}"
