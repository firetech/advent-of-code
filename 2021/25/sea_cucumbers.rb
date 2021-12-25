file = 'input'
#file = 'example1'

@map = File.read(file).strip.split("\n").map { |line| line.chars }

def step(map)
  moved = false
  # Move east-facing herd
  east_map = map.map do |line|
    new_line = Array.new(line.length)
    line.each_with_index do |c, x|
      next_x = (x + 1) % line.length
      if c == '>' and line[next_x] == '.'
        new_line[x] = '.'
        new_line[next_x] = '>'
        moved = true
      elsif new_line[x].nil?
        new_line[x] = c
      end
    end
    new_line
  end
  # Move south-facing herd
  new_map = Array.new(east_map.length) { Array.new(east_map.first.length) }
  east_map.each_with_index do |line, y|
    next_y = (y + 1) % east_map.length
    line.each_with_index do |c, x|
      if c == 'v' and east_map[next_y][x] == '.'
        new_map[next_y][x] = 'v'
        new_map[y][x] = '.'
        moved = true
      elsif new_map[y][x].nil?
        new_map[y][x] = c
      end
    end
  end
  return new_map, moved
end

map = @map
steps = 0
print "Moving.."
begin
  print '.' if steps % 50 == 0
  map, moved = step(map)
  steps += 1
end while moved
puts " Done"

puts "Steady state reached at #{steps} steps"
