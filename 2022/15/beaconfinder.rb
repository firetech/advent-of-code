require_relative '../../lib/aoc_api'

file = ARGV[0] || AOC.input_file()
@p1_y = (ARGV[1] || 2000000).to_i;
@p2_max = (ARGV[2] || 4000000).to_i

#file = 'example1'; @p1_y = 10; @p2_max = 20
#file = 'evil_example'; @p1_y = 2; @p2_max = 4

def dist((x1, y1), (x2, y2))
  return (x1 - x2).abs + (y1 - y2).abs
end

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
    @min_range = dist([@x, @y], [@beacon_x, @beacon_y])
  end

  def in_range_of?(point)
    return dist([@x, @y], point) <= @min_range
  end

  def borders
    if @borders.nil?
      @borders = [
        [@x - @min_range, @y, @x, @y - @min_range],
        [@x - @min_range, @y, @x, @y + @min_range],
        [@x, @y - @min_range, @x + @min_range, @y],
        [@x, @y + @min_range, @x + @min_range, @y]
      ].map do |x1, y1, x2, y2|
        # y = mx + c
        m = y2 <=> y1
        c = y1 - m * x1
        # x1 < x2, always, so x1..x2 is the range for x
        [m, c, x1, x2]
      end
    end
    return @borders
  end
end

t1 = Time.now
@sensors = File.read(file).rstrip.split("\n").map { |line| Sensor.new(line) }

t2 = Time.now

# Part 1
beacons_at_y = @sensors.select { |s| s.beacon_y == @p1_y }.map(&:beacon_x).uniq
# Find all covered ranges of x at y=@p1_y
x_ranges = []
@sensors.each do |s|
  dx_at_y = s.min_range - (@p1_y - s.y).abs
  x_ranges << [s.x - dx_at_y, s.x + dx_at_y] if dx_at_y >= 0
end
# Merge ranges
merged_ranges = []
x_ranges.sort_by(&:first).each do |r|
  if not merged_ranges.empty?
    last = merged_ranges.last
    if last[1] >= r[0]
      last[1] = r[1] if last[1] < r[1]
      next
    end
  end
  merged_ranges << r
end
in_range_x = merged_ranges.map { |r| r[1] - r[0] + 1 }.sum - beacons_at_y.count
puts "At y=#{@p1_y}, #{in_range_x} positions can't contain a beacon"

t3 = Time.now

# Part 2
borders = @sensors.inject([]) { |all, s| all.push(*s.borders) }

def find_intersection(l1, l2)
  if l1[0] != l2[0] # Lines can intersect at all
    m1, c1, x_min1, x_max1 = l1
    m2, c2, x_min2, x_max2 = l2
    x = (c2 - c1)/(m1 - m2).to_f
    if x.between?(x_min1, x_max1) and x.between?(x_min2, x_max2)
      x = x.to_i if (x - x.floor).zero?
      y = (m1 * c2 - m2 * c1)/(m1 - m2).to_f
      y = y.to_i if (y - y.floor).zero?
      return [x, y]
    end
  end
  return nil
end

intersections = []
borders.combination(2).each do |l1, l2|
  i = find_intersection(l1, l2)
  intersections << i unless i.nil?
end
pairs = intersections.uniq.combination(2).select { |a, b| dist(a, b) == 2 }
diamonds = pairs.combination(2).select do |pair1, pair2|
  pair1.product(pair2).all? do |a, b|
    # Allow for half-point intersections, example (file evil_example):
    #  c|ac|ac|a |a
    # --+--+--+--+--
    # bc| c|a |a |a
    # --+--+--+--+--
    # bc|b |XX|a |ad
    # --+--+--+--+--
    # b |b |b | d|ad
    # --+--+--+--+--
    # b |b |bd|bd| d
    # (These have manhattan distance 4 instead of 2)
    a_int = a.all?(&:integer?)
    b_int = b.all?(&:integer?)
    a_int == b_int and dist(a, b) == (a_int ? 2 : 4)
  end
end
diamonds.map { |d| d.flatten(1).sort }.uniq.each do |d|
  x = (d.map(&:first).min + 1).round
  next unless x.between?(0, @p2_max)
  y = (d.map(&:last).min + 1).round
  next unless y.between?(0, @p2_max)
  next if @sensors.any? { |s| s.in_range_of?([x, y]) }
  puts "Beacon at x=#{x}, y=#{y}. Tuning frequency: #{x * 4000000 + y}"
end

t4 = Time.now
puts
puts 'Total: %f, parse: %f, part 1: %f, part 2: %f' % [
  t4 - t1,
  t2 - t1,
  t3 - t2,
  t4 - t3
]
