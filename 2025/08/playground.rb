require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file(); part1_connections = (ARGV[1] || 1000).to_i
#file = 'example1'; part1_connections = 10

@boxes = File.read(file).rstrip.split("\n").map do |line|
  line.split(',').map(&:to_i)
end

@connections = @boxes.combination(2).map do |box1, box2|
  x1, y1, z1 = box1
  x2, y2, z2 = box2
  dist = Math.sqrt((x1-x2).abs**2 + (y1-y2).abs**2 + (z1-z2).abs**2)
  [box1, box2, dist]
end

@connections.sort_by!(&:last)

@box_circuit = {}
@circuits = {}
@next_circ = 1
@next_i = 0
def connect
  return if @next_i >= @connections.length
  box1, box2, _ = @connections[@next_i]
  @next_i += 1
  circ1 = @box_circuit[box1]
  circ2 = @box_circuit[box2]
  if circ1.nil? and circ2.nil?
    @box_circuit[box1] = @next_circ
    @box_circuit[box2] = @next_circ
    @circuits[@next_circ] = [box1, box2]
    @next_circ += 1
  elsif circ1.nil?
    @box_circuit[box1] = circ2
    @circuits[circ2] << box1
  elsif circ2.nil?
    @box_circuit[box2] = circ1
    @circuits[circ1] << box2
  elsif circ1 != circ2
    c2_boxes = @circuits.delete(circ2)
    @circuits[circ1] += c2_boxes
    c2_boxes.each { |b| @box_circuit[b] = circ1 }
  end
  return box1, box2
end

# Part 1
part1_connections.times { connect }
largest3 = @circuits.values.map(&:length).sort.last(3)
puts "Sizes of the largest 3 circuits: #{largest3.inject(:*)}"

# Part 2
while @circuits.count > 1 or @box_circuit.count < @boxes.length
  box1, box2 = connect
end
puts "Product of last X coordinates: #{box1.first * box2.first}"
