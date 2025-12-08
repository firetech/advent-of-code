require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file(); part1_connections = (ARGV[1] || 1000).to_i
#file = 'example1'; part1_connections = 10

@max_coord = 0
@boxes = File.read(file).rstrip.split("\n").map do |line|
  coords = line.split(',').map(&:to_i)
  max_coord = coords.max
  @max_coord = max_coord if max_coord > @max_coord
  coords
end

COORD_BITS = Math.log2(@max_coord).floor + 1
def to_box(coords)
  x, y, z = coords
  return (x << COORD_BITS | y ) << COORD_BITS | z
end

@connections = []
# Sorting by distance squared should give the same result as by distance.
# => We can skip sqrt().
max_dist2 = @max_coord**2 * 3
dist2_cutoff = max_dist2 / 75  # Reasonable-ish cutoff, chosen by feel.
num_boxes = @boxes.length
@boxes.each_with_index do |coords1, i|
  x1, y1, z1 = coords1
  ((i+1)...num_boxes).each do |j|
    coords2 = @boxes[j]
    x2, y2, z2 = coords2
    dist2 = (x1-x2)**2 + (y1-y2)**2 + (z1-z2)**2
    next if dist2 > dist2_cutoff
    @connections << [
      dist2,
      coords1,
      coords2,
    ]
  end
end

@connections.sort_by!(&:first)

@box_circuit = {}
@circuits = {}
@boxes.each_with_index do |coords, i|
  box = to_box(coords)
  @box_circuit[box] = i
  @circuits[i] = [box]
end

@next_i = 0
def connect
  raise "No more connections" if @next_i >= @connections.length
  _, coords1, coords2 = @connections[@next_i]
  @next_i += 1
  circ1 = @box_circuit[to_box(coords1)]
  circ2 = @box_circuit[to_box(coords2)]
  if circ1 != circ2
    c2_boxes = @circuits.delete(circ2)
    @circuits[circ1] += c2_boxes
    c2_boxes.each { |b| @box_circuit[b] = circ1 }
  end
  return coords1.first, coords2.first
end

# Part 1
part1_connections.times { connect }
largest3 = @circuits.values.map(&:length).sort.last(3)
puts "Product of the largest 3 circuit sizes: #{largest3.inject(:*)}"

# Part 2
while @circuits.count > 1
  x1, x2 = connect
end
puts "Product of last X coordinates: #{x1*x2}"
