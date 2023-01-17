require 'set'
require_relative '../../lib/aoc_api'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

input = []
File.read(file).strip.split("\n").each_with_index do |line, y|
  line.each_char.with_index do |char, x|
    if char == '#'
      input << [x, y]
    end
  end
end

def active_cubes(input, dimensions, cycles = 6)
  puts "#{dimensions} dimensions, #{cycles} cycles:"
  state = {}
  input.each do |x, y|
    pos = [x, y, *([0] * (dimensions - 2))]
    state[pos.hash] = [pos, true, 0]
  end
  total = 0
  pos_offsets = [-1, 0, 1].repeated_permutation(dimensions).select { |dp| dp.any? { |p| p != 0 } }
  cycles.times do |c|
    start = Time.now
    state.keys.each do |key|
      pos = state[key][0]
      pos_offsets.each do |dpos|
        npos = pos.zip(dpos).map { |p, dp| p + dp }
        key = npos.hash
        neighbour = state[key]
        if neighbour.nil?
          state[key] = [npos, false, 1]
        else
          neighbour[2] += 1
        end
      end
    end
    new_state = {}
    state.each do |key, (pos, active, neighbours)|
      if (active and (neighbours == 2 or neighbours == 3)) or (not active and neighbours == 3)
        new_state[key] = [pos, true, 0]
      end
    end
    state = new_state
    stop = Time.now
    time = stop - start
    total += time
    puts "* Cycle #{c + 1}: #{state.count} active cubes, #{time.round(2)}s"
  end
  puts "(Total: #{total.round(2)}s)"
end

# Part 1
active_cubes(input, 3)
puts

# Part 2
active_cubes(input, 4)

