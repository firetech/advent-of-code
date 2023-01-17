require_relative '../../lib/aoc_api'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@stars = []
File.read(file).strip.split("\n").each do |line|
  if line =~ /\Aposition=<\s*(-?\d+),\s*(-?\d+)> velocity=<\s*(-?\d+),\s*(-?\d+)>\z/
    _, x, y, vx, vy = Regexp.last_match.to_a.map(&:to_i)
    @stars << [[x, y], [vx, vy]]
  else
    raise "Malformed line: '#{line}'"
  end
end

def positions(time)
  xs = []
  ys = []
  @stars.each do |(x, y), (vx, vy)|
    xs << x + time * vx
    ys << y + time * vy
  end
  return xs, ys
end

time = 0
size = nil
begin
  last_size = size || Float::INFINITY
  time += 1
  xs, ys = positions(time)
  size = (xs.max - xs.min) * (ys.max - ys.min)
end while size < last_size
xs, ys = positions(time - 1)

# Part 1
pos = xs.zip(ys)
x_min = xs.min
x_max = xs.max
ys.min.upto(ys.max) do |y|
  x_min.upto(xs.max) do |x|
    if pos.include?([x, y])
      print '#'
    else
      print ' '
    end
  end
  puts
end

# Part 2
puts "Delay: #{time - 1}"
