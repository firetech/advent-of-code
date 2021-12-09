file = 'input'
#file = 'example1'

@map = File.read(file).strip.split("\n").map do |line|
  line.chars.map(&:to_i)
end

# Part 1
xrange = (0...@map.first.length)
yrange = (0...@map.length)
risk = 0
low_points = []
@map.each_with_index do |line, y|
  line.each_with_index do |val, x|
    low = [[0, -1], [0, 1], [-1, 0], [1, 0]].all? do |dx, dy|
      px, py = x + dx, y + dy
      not (xrange.include?(px) and yrange.include?(py)) or @map[py][px] > val
    end
    if low
      low_points << [x, y]
      risk += val + 1
    end
  end
end

puts "Risk level: #{risk}"

# Part 2
@basin_map = {}
@basin_size = Hash.new(0)
queue = low_points.map.with_index { |(x, y), i| [x, y, i] }
queue.each do |x, y, basin|
  @basin_map[[x, y]] = basin
  @basin_size[basin] += 1
end
while not queue.empty?
  x, y, basin = queue.shift
  [[0, -1], [0, 1], [-1, 0], [1, 0]].each do |dx, dy|
    px, py = x + dx, y + dy
    if xrange.include?(px) and yrange.include?(py) and @map[py][px] < 9
      current_basin = @basin_map[[px, py]]
      if current_basin.nil?
        @basin_map[[px, py]] = basin
        @basin_size[basin] += 1
        queue << [px, py, basin]
      elsif current_basin != basin
        raise "Unexpected basin merge"
      end
    end
  end
end

basin_product = @basin_size.values.sort.last(3).inject(:*)
puts "Product of sizes of three largest basins: #{basin_product}"
