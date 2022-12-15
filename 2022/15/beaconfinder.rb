file = ARGV[0] || 'input'; @p1_y = ARGV[1] || 2000000; @p2_max = ARGV[2] || 4000000
#file = 'example1'; @p1_y = 10; @p2_max = 20

class Sensor
  attr_reader :x, :y, :beacon_x, :beacon_y, :min_range

  def initialize(line)
    if line =~ /\ASensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)\z/
      @x = Regexp.last_match(1).to_i
      @y = Regexp.last_match(2).to_i
      @beacon_x = Regexp.last_match(3).to_i
      @beacon_y = Regexp.last_match(4).to_i
    else
      raise "Malformed line: '#{line}'"
    end
    @min_range = (@x - @beacon_x).abs + (@y - @beacon_y).abs
  end

  def in_range_of(x, y)
    (@x - x).abs + (@y - y).abs <= @min_range
  end
end

@sensors = File.read(file).rstrip.split("\n").map { |line| Sensor.new(line) }

# Part 1
beacons_at_y = @sensors.select { |s| s.beacon_y == @p1_y }.map(&:beacon_x).uniq
# Find all covered ranges of x at y=@p1_y
x_ranges = []
@sensors.each do |s|
  dx_at_y = s.min_range - (@p1_y - s.y).abs
  x_ranges << ((s.x - dx_at_y)..(s.x + dx_at_y)) if dx_at_y >= 0
end
# Merge ranges
merged_ranges = []
x_ranges.sort_by(&:min).each do |r|
  if not merged_ranges.empty? and merged_ranges.last.max >= r.min
    new_max = [merged_ranges.last.max, r.max].max
    merged_ranges[-1] = (merged_ranges.last.min..new_max)
  else
    merged_ranges << r
  end
end
in_range_x = merged_ranges.map(&:size).sum - beacons_at_y.count
puts "At y=#{@p1_y}, #{in_range_x} positions can't contain a beacon"


# Part 2
require 'set'

@pos_range = 0..@p2_max

# Since we want to find a _single_ point not in range of any sensor, it must
# be _just_ outside the range of all nearby sensors.
# First find all pairs of sensors that have an uncovered line of with 1 between
# them.
@pairs = @sensors.combination(2).select do |a, b|
  ((a.x - b.x).abs + (a.y - b.y).abs) == (a.min_range + b.min_range + 2)
end

# Find mid-point and slope for each pair
@diags = [[-1, -1], [-1, 1], [1, -1], [1, 1]]
@pairs.map! do |pair|
  # Find mid point
  dist = pair.map(&:min_range).sum + 2.0
  by_x = pair.sort_by(&:x)
  x = (by_x.first.x + ((by_x.first.min_range + 2) / dist) *
        (by_x.last.x - by_x.first.x)).floor
  by_y = pair.sort_by(&:y)
  y = (by_y.first.y + ((by_y.first.min_range + 2) / dist) *
        (by_y.last.y - by_y.first.y)).floor
  diags = @diags.select do |dx, dy|
    px = x + dx
    py = y + dy
    @pos_range.include?(px) and @pos_range.include?(py) and
      pair.none? { |s| s.in_range_of(px, py) }
  end
  raise 'Ehm?' if diags.length != 2 and diags.length != 1
  pair.push(diags, x, y)
end

# Then, since we're working with Manhattan distance, to encircle a single,
# uncovered point, we need four distinct sensors, so find all pairs of pairs
# with four unique sensors between them, that give perpendicular lines.
@groups = @pairs.combination(2).select do |(a, b, diags1), (c, d, diags2)|
  a != c and b != c and a != d and b != d and (diags1 & diags2).empty?
end

# Lastly, follow the diagonals until we find a common point.
# This can probably be done faster with pure math, but I can't be bothered...
def key(x, y)
  return y << 22 | x
end
def find_frequency
  walks = @groups.map do |pairs|
    seen = Set[]
    group_walks = pairs.flat_map do |_, _, diags, x, y|
      start = key(x, y)
      # Lucky?
      return x, y if seen.include?(start)
      seen << start
      diags.map { |dx, dy| [x + dx, y + dy, dx, dy] }
    end
    [group_walks, seen]
  end
  until walks.empty?
    walks.reject! do |group_walks, seen|
      group_walks.select! do |w|
        w[0] += w[2] # x += dx
        w[1] += w[3] # y += dy
        if @pos_range.include?(w[0]) and @pos_range.include?(w[1])
          point = key(w[0], w[1])
          return w[0], w[1] if seen.include?(point)
          seen << point
          true # keep walking
        else
          false # discard walk
        end
      end
      group_walks.empty?
    end
  end
end
x, y = find_frequency
puts "Beacon at x=#{x}, y=#{y}. Tuning frequency: #{x * 4000000 + y}"
