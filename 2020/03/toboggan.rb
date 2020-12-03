input = File.read('input').strip.split("\n")
#input = File.read('example1').strip.split("\n")

@map = []
input.each do |line|
  @map << line.each_char.map { |x| x == '#' }
end

def check_slope(right, down)
  x = 0
  trees = 0
  (0...(@map.length)).step(down) do |y|
    if @map[y][x % @map[y].length]
      trees += 1
    end
    x += right
  end
  return trees
end

#part 1
slope31 = check_slope(3, 1)
puts "#{slope31} trees would be encountered on slope (3, 1)."

#part 2
product = check_slope(1, 1) *
          slope31 *
          check_slope(5, 1) *
          check_slope(7, 1) *
          check_slope(1, 2)
puts "Product of encountered trees on listed slopes: #{product}"
