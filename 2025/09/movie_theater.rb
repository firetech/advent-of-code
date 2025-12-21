require_relative '../../lib/aoc'
require_relative '../../lib/multicore'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@tiles = File.read(file).rstrip.split("\n").map do |line|
  line.split(',').map(&:to_i)
end

# Part 1
@areas = @tiles.combination(2).map do |(x1, y1), (x2, y2)|
  area = ((x1 - x2).abs + 1) * ((y1 - y2).abs + 1)
  [area, x1, y1, x2, y2]
end
@areas.sort_by! { |a| -a.first }
puts "Largest rectangle area: #{@areas.first.first}"

# Part 2
@lines = []
px1, py1 = @tiles.last
@tiles.each do |px2, py2|
  if px1 <= px2
    min_px = px1
    max_px = px2
  else
    min_px = px2
    max_px = px1
  end
  if py1 <= py2
    min_py = py1
    max_py = py2
  else
    min_py = py2
    max_py = py1
  end

  # Vertical/horizontal lines only, length is easy
  length = max_px - min_px + max_py - min_py
  @lines << [length, min_px, max_px, min_py, max_py]

  px1 = px2
  py1 = py2
end
@lines.sort_by! { |l| -l.first }

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
def rectangle_ok?(x1, y1, x2, y2)
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

  @lines.each do |_, min_px, max_px, min_py, max_py|
    if min_py == max_py
      return false if min_y < min_py and min_py < max_y and
          ((min_px <= min_x and min_x < max_px) or
            (min_px < max_x and max_x <= max_px))
    elsif min_px == max_px
      return false if min_x < min_px and min_px < max_x and
          ((min_py <= min_y and min_y < max_py) or
            (min_py < max_y and max_y <= max_py))
    else
      raise "Polygon not rectilinear"
    end
  end

  return true
end

@largest_area2 = 0
stop = nil
begin
  n_areas = @areas.length
  _, output, stop, n_runners = Multicore.run(-n_areas) do |_, worker_out, runner, n_runners|
    largest_area = 0
    runner.step(n_areas-1, n_runners) do |i|
      area, x1, y1, x2, y2 = @areas[i]
      if rectangle_ok?(x1, y1, x2, y2)
        largest_area = area
        break # Areas are already sorted by size
      end
    end
    worker_out[largest_area]
  end
  n_runners.times do
    area = output.pop
    @largest_area2 = area if area > @largest_area2
  end
ensure
  stop[] unless stop.nil?
end
puts "Largest rectangle area within boundary: #{@largest_area2}"
