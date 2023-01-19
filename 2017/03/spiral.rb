require_relative '../../lib/aoc'

input = (ARGV[0] || AOC.input()).to_i
#input = 1
#input = 12
#input = 23
#input = 1024

# Part 1
layer = (Math.sqrt(input).ceil.to_i / 2) + 1
l_size = layer * 2 - 1
prev_max = [0, (l_size - 2)**2].max
side = (input - prev_max - 1) / (l_size - 1) rescue 0
midpoint = prev_max + (side*2 + 1) * (layer - 1)

puts "Steps to #{input}: #{(layer - 1) + (input - midpoint).abs}"

# Part 2
# You could use https://oeis.org/A141481 for this, but...
require 'matrix'

DIRS = [
  #       Δx  Δy
  Vector[  1,  0],
  Vector[  0, -1],
  Vector[ -1,  0],
  Vector[  0,  1]
]
NEIGHBOURS = DIRS + [
  Vector[  1,  1],
  Vector[  1, -1],
  Vector[ -1,  1],
  Vector[ -1, -1]
]
pos = Vector[0, 0]
dir = 0
steps = 1
step_diff = 0
grid = {
  pos => 1
}

continue = true
while continue
  steps.times do
    pos += DIRS[dir]
    x = NEIGHBOURS.sum { |delta| grid[pos + delta] or 0 }
    grid[pos] = x
    if x > input
      puts "First value larger than #{input}: #{x}"
      continue = false
      break
    end
  end
  steps += step_diff
  step_diff = 1 - step_diff
  dir = (dir + 1) % DIRS.length
end
