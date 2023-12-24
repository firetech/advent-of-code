require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
min_xy = (ARGV[1] || 200_000_000_000_000).to_i
max_xy = (ARGV[2] || 400_000_000_000_000).to_i
#file = 'example1'; min_xy = 7; max_xy = 27

@hailstones = []
File.read(file).rstrip.split("\n").each do |line|
  case line
  when /\A(\d+),\s+(\d+),\s+(\d+)\s+@\s+(-?\d+),\s+(-?\d+),\s+(-?\d+)\z/
    @hailstones << [
      [ Regexp.last_match(1).to_i, Regexp.last_match(2).to_i, Regexp.last_match(3).to_i],
      [ Regexp.last_match(4).to_i, Regexp.last_match(5).to_i, Regexp.last_match(6).to_i]
    ]
  else
    raise "Malformed line: '#{line}'"
  end
end

# Part 1
count = 0
@hailstones.combination(2) do |a,b|
  # https://en.wikipedia.org/wiki/Line%E2%80%93line_intersection#Given_two_points_on_each_line_segment
  (x1, y1, _), (dx2, dy2, _) = a
  x2 = x1 + dx2
  y2 = y1 + dy2
  (x3, y3, _), (dx4, dy4, _) = b
  x4 = x3 + dx4
  y4 = y3 + dy4
  t = ((x1-x3)*(y3-y4) - (y1-y3)*(x3-x4)).to_f/((x1-x2)*(y3-y4) - (y1-y2)*(x3-x4)).to_f
  x = x1 + t*dx2
  next if x < min_xy or x > max_xy
  next if (x1 <=> x2) != (x1 <=> x) or (x3 <=> x4) != (x3 <=> x)
  y = y1 + t*dy2
  next if y < min_xy or y > max_xy
  next if (y1 <=> y2) != (y1 <=> y) or (y3 <=> y4) != (y3 <=> y)
  count += 1
end
puts "Hailstones intersecting within range on XY plane: #{count}"

# Part 2
require 'z3'
solver = Z3::Solver.new
x = Z3.Int('x'); dx = Z3.Int('dx')
y = Z3.Int('y'); dy = Z3.Int('dy')
z = Z3.Int('z'); dz = Z3.Int('dz')
@hailstones.each_with_index do |((hx, hy, hz), (hdx, hdy, hdz)), i|
  t = Z3.Int("t#{i}")
  solver.assert(x + t*dx == hx + t*hdx)
  solver.assert(y + t*dy == hy + t*hdy)
  solver.assert(z + t*dz == hz + t*hdz)
end
raise 'Unsatisfiable?!' unless solver.satisfiable?
sum = solver.model[x].to_i + solver.model[y].to_i + solver.model[z].to_i
puts "Sum of rock coordinates: #{sum}"
