file = ARGV[0] || 'input'; @part1_y = ARGV[1] || 2000000; @part2_max = 4000000
#file = 'example1'; @part1_y = 10; @part2_max = 20

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
xs = @sensors.flat_map { |s| [s.x - s.min_range, s.x + s.min_range] }

@in_range_x = 0
xs.min.upto(xs.max) do |x|
  @in_range_x += 1 if @sensors.any? { |s| s.in_range_of(x, @part1_y) } and not @sensors.any? { |s| s.beacon_x == x and s.beacon_y == @part1_y }
end

puts "At y=#{@part1_y}, #{@in_range_x} positions can't contain a beacon"

# Part 2
@pos_range = 0..@part2_max
def find_beacon
  # Since we want to find a _single_ point not in range of any sensor, it must
  # be _just_ outside the range of all nearby sensors.
  # Therefore, checking all positions in the ring one step away from being in
  # range of each sensor, we will find the position not in range of any sensor.
  @sensors.each do |s|
    range = s.min_range + 1
    [-1, 1].each do |y_dir|
      [-1, 1].each do |x_dir|
        0.upto(range) do |dx|
          dy = range - dx
          x = s.x + dx * x_dir
          next unless @pos_range.include?(x)
          y = s.y + dy * y_dir
          next unless @pos_range.include?(y)
          if not @sensors.any? { |s| s.in_range_of(x, y) }
            return x, y
          end
        end
      end
    end
  end
end
x, y = find_beacon
puts "Beacon at x=#{x}, y=#{y}. Tuning frequency: #{x * 4000000 + y}"
