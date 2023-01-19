require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'
#file = 'example2'

@octopi = File.read(file).strip.split("\n").map { |l| l.chars.map(&:to_i) }

octopi = @octopi
xrange = 0...octopi.first.length
yrange = 0...octopi.length
all_octopi = octopi.length * octopi.first.length
all_synced = -1
flashes = 0
i = 0
while i < 100 or all_synced < 0
  flashing = []
  octopi = octopi.map.with_index do |line, y|
    line.map.with_index do |octopus, x|
      new_level = octopus + 1
      if new_level > 9
        flashing << [x, y]
      end
      new_level
    end
  end
  flashed = []
  while not flashing.empty?
    x, y = flashing.shift
    flashed << [x, y]
    flashes += 1 if i < 100
    [-1, 0, 1].repeated_permutation(2) do |dx, dy|
      next if dx == 0 and dy == 0
      px, py = x + dx, y + dy
      next unless xrange.include?(px) and yrange.include?(py)
      next if octopi[py][px] > 9
      octopi[py][px] += 1
      if octopi[py][px] > 9
        flashing << [px, py]
      end
    end
  end
  flashed.each do |x, y|
    octopi[y][x] = 0
  end
  i += 1
  if flashed.length == all_octopi and all_synced < 0
    all_synced = i
  end
end

# Part 1
puts "Flashes after 100 steps: #{flashes}"

# Part 2
puts "First step of synchronized flash: #{all_synced}"
