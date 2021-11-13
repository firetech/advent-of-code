file = 'input'
#file = 'example1'

input = File.read(file).strip.split("\n").map(&:chars)

if input.map(&:length).uniq.length > 1
  raise "Input lines are not equal length"
end

GRID_SIZE = 501
if input.length > GRID_SIZE or input.first.length > GRID_SIZE
  raise "GRID_SIZE too small"
end

@grid = Array.new(GRID_SIZE*GRID_SIZE, false)
x_offset = GRID_SIZE/2 - input.first.length/2
y_offset = GRID_SIZE/2 - input.length/2
input.each_with_index do |line, y|
  line.each_with_index do |char, x|
    if char == '#'
      i = (y+y_offset) * GRID_SIZE + x+x_offset
      @grid[i] = true
    end
  end
end

TURN_LEFT = { up: :left, left: :down, down: :right, right: :up }
TURN_RIGHT = { up: :right, right: :down, down: :left, left: :up }
TURN_AROUND = { up: :down, down: :up, left: :right, right: :left }

[
  [1, 10_000],
  [2, 10_000_000]
].each do |algo, bursts|
  grid = @grid.clone
  dir = :up
  x = GRID_SIZE/2
  y = GRID_SIZE/2
  infections = 0
  bursts.times do
    i = y * GRID_SIZE + x
    case algo
    when 1
      # Part 1
      if grid[i]
        dir = TURN_RIGHT[dir]
        grid[i] = false
      else
        dir = TURN_LEFT[dir]
        grid[i] = true
        infections += 1
      end
    when 2
      # Part 2
      case grid[i]
      when false
        dir = TURN_LEFT[dir]
        grid[i] = :weak
      when :weak
        grid[i] = true
        infections += 1
      when true
        dir = TURN_RIGHT[dir]
        grid[i] = :flag
      when :flag
        dir = TURN_AROUND[dir]
        grid[i] = false
      end
    end

    case dir
    when :up
      y -= 1
      valid = (y >= 0)
    when :down
      y += 1
      valid = (y < GRID_SIZE)
    when :left
      x -= 1
      valid = (x >= 0)
    when :right
      x += 1
      valid = (x < GRID_SIZE)
    end
    raise "Out of bounds, increase GRID_SIZE" unless valid
  end
  puts "#{infections} infections in #{bursts} bursts with algorithm #{algo}"
end
