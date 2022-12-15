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
@pos_range = 0..@p2_max
@dirs = [-1, 1].product([-1, 1])
def find_beacon
  # Since we want to find a _single_ point not in range of any sensor, it must
  # be _just_ outside the range of all nearby sensors.
  # Therefore, checking all positions in the ring one step away from being in
  # range of each sensor, we will find the position not in range of any sensor.
  @sensors.each do |s|
    dist = s.min_range + 1
    @dirs.each do |y_dir, x_dir|
      0.upto(dist) do |dx|
        x = s.x + dx * x_dir
        next unless @pos_range.include?(x)
        y = s.y + (dist - dx) * y_dir
        next unless @pos_range.include?(y)
        return x, y unless @sensors.any? { |s| s.in_range_of(x, y) }
      end
    end
  end
  raise "No beacon found?"
end
x, y = find_beacon
puts "Beacon at x=#{x}, y=#{y}. Tuning frequency: #{x * 4000000 + y}"
