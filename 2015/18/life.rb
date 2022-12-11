input = File.read('input').strip
#input = File.read('example').strip

STEPS = 100
#STEPS = 4  # Part 1 example
#STEPS = 5  # Part 2 example

# Part 1
@lights = input.split("\n").map { |line| line.each_char.map { |c| c == '#' } }

def step(lights, force_corners = false)
  rows = lights.length
  cols = lights.first.length
  new_lights = Array.new(rows) { Array.new(cols, false) }
  if force_corners
    new_lights[0][0] = new_lights[0][cols-1] = new_lights[rows-1][0] = new_lights[rows-1][cols-1] = true
  end
  # Ported from my decades old game of life implementation in Java, http://firetech.nu/files/yagol/
  # It isn't stealing if I copy myself, right? ;)
  rows.times do |y|
    cols.times do |x|
      neighbours = 0
      (([y-1, 0].max)..([y+1, rows-1].min)).each do |ny|
        (([x-1, 0].max)..([x+1, cols-1].min)).each do |nx|
          if (ny != y  or nx != x) and lights[ny][nx]
            neighbours += 1
          end
        end
      end
      if (lights[y][x] and [2, 3].include?(neighbours)) or
          (not lights[y][x] and [3].include?(neighbours))
        new_lights[y][x] = true
      end
    end
  end
  return new_lights
end

lights = @lights
STEPS.times do
  lights = step(lights)
end

puts "#{lights.map { |line| line.count(true) }.sum} lights are on"

# Part 2
lights = @lights.map(&:clone)
rows = lights.length
cols = lights.first.length
lights[0][0] = lights[0][cols-1] = lights[rows-1][0] = lights[rows-1][cols-1] = true
STEPS.times do
  lights = step(lights, true)
end

puts "#{lights.map { |line| line.count(true) }.sum} lights are on when corners are stuck"
