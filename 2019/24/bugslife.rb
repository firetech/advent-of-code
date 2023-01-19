require_relative '../../lib/aoc'

input = File.read(ARGV[0] || AOC.input_file()).strip
@minutes = (ARGV[1] || 200).to_i

#input = File.read('example').strip; @minutes = 10

require 'set'

@grid = input.split("\n").map do |line|
  line.chars.map { |c| c == '#' }
end

def step(grid)
  rows = grid.length
  cols = grid.first.length
  new_grid = Array.new(rows) { Array.new(cols, false) }
  rows.times do |y|
    cols.times do |x|
      neighbours = yield x, y, grid, cols, rows
      if (grid[y][x] and [1].include?(neighbours)) or
          (not grid[y][x] and [1,2].include?(neighbours))
        new_grid[y][x] = true
      end
    end
  end
  return new_grid
end

# part 1
seen = Set.new
last_grid = @grid
last_hash = @grid.hash
until seen.include?(last_hash)
  seen << last_hash
  last_grid = step(last_grid) do |x, y, grid, cols, rows|
    neighbours = 0
    [[0, -1], [-1, 0], [1, 0], [0, 1]].each do |x_delta, y_delta|
      nx = x + x_delta
      next if nx < 0 or nx >= cols
      ny = y + y_delta
      next if ny < 0 or ny >= rows
      neighbours += 1 if grid[ny][nx]
    end
    neighbours
  end
  last_hash = last_grid.hash
end

diversity = 0
val = 1
last_grid.flatten.each do |cell|
  diversity += val if cell
  val <<= 1
end
puts "Diversity of first repeating pattern: #{diversity}"

# part 2
def rec_neigbours(x, y, grid, cols, rows, sub_grid, super_grid)
  return 0 if x == 2 and y == 2
  neighbours = 0
  [[0, -1], [-1, 0], [1, 0], [0, 1]].each do |x_delta, y_delta|
    nx = x + x_delta
    ny = y + y_delta
    rec_coords = nil
    rec_grid = nil
    if nx == 2 and ny == 2
      # sub-grid
      rec_grid = sub_grid
      case [x, y]
      when [2, 1]
        rec_coords = (0..4).map { |x| [x, 0] }
      when [1, 2]
        rec_coords = (0..4).map { |y| [0, y] }
      when [3, 2]
        rec_coords = (0..4).map { |y| [4, y] }
      when [2, 3]
        rec_coords = (0..4).map { |x| [x, 4] }
      end
    elsif nx < 0 or nx >= cols or ny < 0 or ny >= rows
      # super-grid
      rec_grid = super_grid
      if ny == -1
        rec_coords = [[2, 1]]
      elsif nx == -1
        rec_coords = [[1, 2]]
      elsif nx == 5
        rec_coords = [[3, 2]]
      elsif ny == 5
        rec_coords = [[2, 3]]
      end
    else
      neighbours += 1 if grid[ny][nx]
    end
    unless rec_coords.nil?
      neighbours += rec_coords.select { |rx, ry| rec_grid[ry][rx] }.count
    end
  end
  return neighbours
end

@grids = { 0 => @grid }
empty_grid = Array.new(5, Array.new(5, false)) # read-only, row dup is non-issue
@cache = {}
@minutes.times do
  new_grids = {}
  [@grids.keys.min - 1, *@grids.keys, @grids.keys.max + 1].each do |level|
    grid = (@grids[level] or empty_grid)
    sub_grid = (@grids[level + 1] or empty_grid)
    super_grid = (@grids[level - 1] or empty_grid)
    cache_key = [super_grid, grid, sub_grid].hash
    if @cache.has_key?(cache_key)
      new_grid = @cache[cache_key]
    else
      new_grid = step(grid) do |x, y, grid, rows, cols|
        rec_neigbours(x, y, grid, rows, cols, sub_grid, super_grid)
      end
      @cache[cache_key] = new_grid
    end
    if @grids.has_key?(level) or new_grid.flatten.include?(true)
      new_grids[level] = new_grid
    end
  end
  @grids = new_grids
end

puts "Bugs after #{@minutes} minutes: #{@grids.values.flatten.count(true)}"
