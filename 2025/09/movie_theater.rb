require_relative '../../lib/aoc'
require_relative '../../lib/multicore'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@tiles = File.read(file).rstrip.split("\n").map do |line|
  line.split(',').map(&:to_i)
end

# Part 1
@largest_area1 = 0
@tiles.combination(2) do |(x1, y1), (x2, y2)|
  area = ((x1 - x2).abs + 1) * ((y1 - y2).abs + 1)
  @largest_area1 = area if area > @largest_area1
end
puts "Largest rectangle area: #{@largest_area1}"


# Part 2
# Technically not correct, just checking if any edge of the polygon intersects
# the rectangle. Turns out to be good enough for this problem.
#
# Would, however, not work properly in cases like the polygon below, since the
# task is to check grid squares (in which the notch "disappears").
#     +--++--+
#     |  ||  |
#     |  ++  |
#     |      |
#     +------+
# This polygon is available as "test1" in this directory. Answer should be 40
# for both part 1 and 2, but this solution returns 20.
def rectangle_in_polygon?(x1, y1, x2, y2, polygon)
  if x1 <= x2
    min_x = x1
    max_x = x2
  else
    min_x = x2
    max_x = x1
  end
  if y1 <= y2
    min_y = y1
    max_y = y2
  else
    min_y = y2
    max_y = y1
  end

  px1, py1 = polygon.last
  polygon.each do |px2, py2|
    if py1 == py2
      if px1 <= px2
        min_px = px1
        max_px = px2
      else
        min_px = px2
        max_px = px1
      end
      return false if min_y < py1 and py1 < max_y and
          ((min_px <= min_x and min_x < max_px) or
            (min_px < max_x and max_x <= max_px))
    elsif px1 == px2
      if py1 <= py2
        min_py = py1
        max_py = py2
      else
        min_py = py2
        max_py = py1
      end
      return false if min_x < px1 and px1 < max_x and
          ((min_py <= min_y and min_y < max_py) or
            (min_py < max_y and max_y <= max_py))
    else
      raise "Polygon not rectilinear"
    end

    px1 = px2
    py1 = py2
  end

  return true
end

@largest_area2 = 0
stop = nil
begin
  n_combinations = (@tiles.length * (@tiles.length - 1)) / 2
  input, output, stop, nrunners = Multicore.run(-(n_combinations / 2)) do |worker_in, worker_out|
    largest_area = 0
    worker_in[].each do |(x1, y1), (x2, y2)|
      next unless rectangle_in_polygon?(x1, y1, x2, y2, @tiles)
      area = ((x1 - x2).abs + 1) * ((y1 - y2).abs + 1)
      largest_area = area if area > largest_area
    end
    worker_out[largest_area]
  end
  slice = (n_combinations / nrunners.to_f).ceil
  @tiles.combination(2).each_slice(slice) { |list| input << list }
  nrunners.times do
    area = output.pop
    @largest_area2 = area if area > @largest_area2
  end
ensure
  stop[] unless stop.nil?
end
puts "Largest rectangle area within boundary: #{@largest_area2}"
