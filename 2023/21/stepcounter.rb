require 'set'
require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
part1_steps = (ARGV[1] || 64).to_i
part2_steps = (ARGV[2] || 26501365).to_i
#file = 'example1'; part1_steps = 6

@start = nil
@map = File.read(file).rstrip.split("\n").map.with_index do |line, y|
  unless (x = line.index('S')).nil?
    raise "Double start?" unless @start.nil?
    @start = [x, y]
  end
  line.each_char.map { |c| c != '#' }
end
@width = @map.first.length
@height = @map.length

# Part 1
positions = Set[@start]
part1_steps.times do
  new_positions = Set[]
  positions.each do |x, y|
    [[-1, 0], [0, -1], [1, 0], [0, 1]].each do |dx, dy|
      nx = x + dx
      next if nx < 0 or nx >= @width
      ny = y + dy
      next if ny < 0 or ny >= @height
      next unless @map[ny][nx]
      new_positions << [nx, ny]
    end
  end
  positions = new_positions
end
puts "Garden plots reachable in #{part1_steps} steps: #{positions.length}"

# Part 2
raise 'Part 2 will not work with this input' if @width != @height or part2_steps % @width != @start[0]
positions = [Set[@start]]
values = []
steps_mod = part2_steps % @width
part2_steps.times do |s|
  positions << Set[]
  positions[s].each do |x, y|
    [[-1, 0], [0, -1], [1, 0], [0, 1]].each do |dx, dy|
      nx = x + dx
      ny = y + dy
      next unless @map[ny % @height][nx % @width]
      positions[s + 1] << [nx, ny]
    end
  end
  if s % @width == steps_mod
    # Add values of quadratic function
    values << positions[s].length
    break if values.length == 3
  end
end

# Interpolate quadratic function to get the answer
b0 = values[0]
b1 = values[1]-values[0]
b2 = values[2]-values[1]
n = part2_steps / @width
puts "Garden plots reachable in #{part2_steps} steps: #{b0 + b1*n + (n*(n-1)/2)*(b2-b1)}"
