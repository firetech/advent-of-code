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
def orient(ax, ay, bx, by, cx, cy)
  cross = (bx - ax) * (cy - ay) - (by - ay) * (cx - ax)
  return cross <=> 0  # -1, 0 or 1
end

def point_on_segment?(px, py, x1, y1, x2, y2)
  return false if orient(x1, y1, x2, y2, px, py) != 0  # Not colinear
  xs = [x1, x2]
  return false if px < xs.min or px > xs.max
  ys = [y1, y2]
  return false if py < ys.min or py > ys.max
  return true
end

def point_in_polygon?(px, py, polygon)
  inside = false
  x1, y1 = polygon.last
  polygon.each do |x2, y2|
    if point_on_segment?(px, py, x1, y1, x2, y2)
      return true
    end
    if (y1 > py) != (y2 > py)
      x_intersect = (x2 - x1) * (py - y1) / (y2 - y1) + x1
      inside = !inside if px < x_intersect
    end

    x1 = x2
    y1 = y2
  end
  return inside
end

def segment_intersection?(x1, y1, x2, y2, x3, y3, x4, y4)
  return (
    (orient(x1, y1, x2, y2, x3, y3) * orient(x1, y1, x2, y2, x4, y4) < 0) and
    (orient(x3, y3, x4, y4, x1, y1) * orient(x3, y3, x4, y4, x2, y2) < 0)
  )
end

def rectangle_in_polygon?(x1, y1, x2, y2, polygon)
  corners = [
    [x1, y1],
    [x1, y2],
    [x2, y1],
    [x2, y2],
  ]
  corners.each do |cx, cy|
    return false unless point_in_polygon?(cx, cy, polygon)
  end

  edges = [
    [x1, y1, x2, y1],
    [x2, y1, x2, y2],
    [x2, y2, x1, y2],
    [x1, y2, x1, y1],
  ]
  edges.each do |ex1, ey1, ex2, ey2|
    px1, py1 = polygon.last
    polygon.each do |px2, py2|
      return false if segment_intersection?(ex1, ey1, ex2, ey2, px1, py1, px2, py2)

      px1 = px2
      py1 = py2
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
      next unless rectangle_in_polygon?(x1, y1, x2, y2, @tiles)
      largest_area = area if area > largest_area
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
