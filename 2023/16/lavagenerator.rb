require_relative '../../lib/aoc'
require 'set'
require_relative '../../lib/multicore'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@map = File.read(file).rstrip.split("\n")
@width = @map.first.length
@height = @map.length

# +1 to account for positions just outside the map (results Hash)
@y_bits = Math.log2(@height+1).ceil
def to_pos(x, y)
  (x+1) << @y_bits | (y+1)
end
def to_state(x, y, dx, dy)
  to_pos(x, y) << 4 | (dx+1) << 2 | (dy+1)
end

def run(start)
  pos = [start]
  seen = Set[]
  energized = Set[]

  until pos.empty?
    p = pos.shift
    state = to_state(*p)
    next if seen.include?(state)
    seen << state
    x, y, dx, dy = p
    nx = x + dx
    next if nx < 0 or nx >= @width
    ny = y + dy
    next if ny < 0 or ny >= @height
    energized << to_pos(nx, ny)

    unaffected = false
    case @map[ny][nx]
    when '.'
      unaffected = true
    when '/'
      pos << [nx, ny, -dy, -dx]
    when '\\'
      pos << [nx, ny, dy, dx]
    when '-'
      if dy != 0
        pos << [nx, ny, -1, 0]
        pos << [nx, ny, 1, 0]
      else
        unaffected = true
      end
    when '|'
      if dx != 0
        pos << [nx, ny, 0, -1]
        pos << [nx, ny, 0, 1]
      else
        unaffected = true
      end
    else
      raise "Unexpected map character: '#{@map[dy][dx]}'"
    end

    if unaffected
      pos << [nx, ny, dx, dy]
    end
  end

  return energized.length
end

stop = nil
results = {}
begin
  input, output, stop = Multicore.run do |worker_in, worker_out|
    until (start = worker_in[]).nil?
      worker_out[[to_state(*start), run(start)]]
    end
  end
  @height.times do |y|
    input << [-1, y, 1, 0] # Left edge, going right
    input << [@width, y, -1, 0] # Right edge, going left
  end
  @width.times do |x|
    input << [x, -1, 0, 1] # Top edge, going down
    input << [x, @height, 0, -1] # Bottom edge, going up
  end
  ((@width + @height) * 2).times do
    state, count = output.pop
    results[state] = count
  end
ensure
  stop[] unless stop.nil?
end

# Part 1
puts "Energized tiles from top left, going right: #{results[to_state(-1, 0, 1, 0)]}"

# Part 2
puts "Maximum energized tiles: #{results.values.max}"
