file = 'input'
#file = 'example1'

@map = File.read(file).strip.split("\n").map do |line|
  line.chars.map(&:to_i)
end

xrange = (0...@map.first.length)
yrange = (0...@map.length)
risk = 0
low_points = []
@map.each_with_index do |line, y|
  line.each_with_index do |val, x|
    low = [[0, -1], [0, 1], [-1, 0], [1, 0]].all? do |dx, dy|
      px, py = x + dx, y + dy
      if xrange.include?(px) and yrange.include?(py)
        @map[py][px] > val
      else
        true
      end
    end
    if low
      low_points << [x, y]
      risk += val + 1
    end
  end
end

puts "Risk level: #{risk}"

@basin_map = {}
queue = low_points.map.with_index { |(x, y), i| [x, y, i] }
queue.each do |x, y, basin|
  @basin_map[[x, y]] = basin
end
while not queue.empty?
  x, y, basin = queue.shift
  [[0, -1], [0, 1], [-1, 0], [1, 0]].each do |dx, dy|
    px, py = x + dx, y + dy
    next unless xrange.include?(px) and yrange.include?(py)
    if @map[py][px] < 9
      current_basin = @basin_map[[px, py]]
      if current_basin.nil?
        @basin_map[[px, py]] = basin
        queue << [px, py, basin]
      elsif current_basin != basin
        raise "Unexpected basin merge"
      end
    end
  end
end

@basin_size = Hash.new(0)
@basin_map.each_value { |basin| @basin_size[basin] += 1 }
basin_product = @basin_size.values.sort.reverse.first(3).inject(:*)

puts "Product of sizes of three largest basins: #{basin_product}"
