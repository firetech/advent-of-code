require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

input_bricks = []
@max_x = 0
File.read(file).rstrip.split("\n").each do |line|
  case line
  when /\A(\d+),(\d+),(\d+)~(\d+),(\d+),(\d+)\z/
    x_min, x_max = [Regexp.last_match(1).to_i, Regexp.last_match(4).to_i].minmax
    y_min, y_max = [Regexp.last_match(2).to_i, Regexp.last_match(5).to_i].minmax
    z_min, z_max = [Regexp.last_match(3).to_i, Regexp.last_match(6).to_i].minmax
    input_bricks << [
      [x_min, y_min, z_min],
      [
        x_max+1 - x_min,
        y_max+1 - y_min,
        z_max+1 - z_min
      ]
    ]
    @max_x = x_max if x_max > @max_x
  else
    raise "Malformed line: '#{line}'"
  end
end

# Make bricks list bitmask of base and its z values
@bricks = input_bricks.map do |(x, y, z), (sx, sy, sz)|
  mask = 0
  sx.times do |dx|
    xx = x + dx
    sy.times do |dy|
      mask |= 1<< (xx + (y+dy) * (@max_x + 1))
    end
  end
  [mask, z, sz]
end
# Sort by increasing (bottom) z value
@bricks.sort_by! { |mask, z, sz| z }

# Helper functions
def insert(brick, tower)
  mask, z, sz = brick
  sz.times do |dz|
    tower[z+dz] |=mask
  end
end
def disintegrate(brick, tower)
  mask, z, sz = brick
  sz.times do |dz|
    tower[z+dz] ^=mask
  end
end
def fall_brick(brick, tower)
  mask, z, sz = brick
  return nil if tower[z-1] & mask != 0 # Can't fall
  z -= 1 while tower[z-1] & mask == 0
  return mask, z, sz
end

# Let the bricks fall and settle
@tower = Hash.new(0)
@tower[0] = -1
fallen_bricks = []
@bricks.each do |brick|
  fallen_brick = (fall_brick(brick, @tower) or brick)
  insert(fallen_brick, @tower)
  fallen_bricks << fallen_brick
end

unsupportive = 0 # Part 1
fall_sum = 0 # Part 2
# Disintegrate each brick and see what happens to others
fallen_bricks.each_with_index do |brick, i|
  without_this = @tower.dup
  # Remove brick itself
  disintegrate(brick, without_this)
  supporting = 0
  fallen_bricks[i+1..-1].each do |other|
    unless (fallen_other = fall_brick(other, without_this)).nil?
      # Make this brick fall and count it
      disintegrate(other, without_this)
      insert(fallen_other, without_this)
      supporting += 1
    end
  end
  if supporting == 0
    # Part 1
    # This brick isn't supporting any other
    unsupportive += 1
  else
    # Part 2
    # Add the support count to the total
    fall_sum += supporting
  end
end

# Part 1
puts "Bricks not individually supporting any other brick: #{unsupportive}"

# Part 2
puts "Sum of bricks that would fall for each disintegrated brick: #{fall_sum}"
