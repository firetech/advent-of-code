require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
max = (ARGV[1] || 4294967295).to_i

#file = 'example1'; max = 9

input = File.read(file).strip.split("\n").map { |line| line.split('-').map(&:to_i) }
input.sort_by!(&:first)

# Simplify ranges
ranges = []
last_range = nil
input.each do |low, high|
  if not last_range.nil?
    if low <= last_range[1] + 1
      if last_range[1] < high
        last_range[1] = high
      end
    else
      last_range = nil
    end
  end
  if last_range.nil?
    last_range = [low, high]
    ranges << last_range
  end
end
ranges.sort_by!(&:first)

# Part 1
if ranges.first[0] == 0
  lowest = ranges.first[1] + 1
else
  lowest = 0
end
puts "Lowest allowed IP: #{lowest}"

# Part 2
num_allowed = 0
last_high = -1
ranges.each do |low, high|
  num_allowed += low - last_high - 1
  last_high = high
end
num_allowed += max - last_high
puts "Allowed IPs: #{num_allowed}"
