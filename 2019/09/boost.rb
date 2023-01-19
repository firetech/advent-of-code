require_relative '../../lib/aoc'
require_relative '../lib/intcode'

input = File.read(ARGV[0] || AOC.input_file()).split(',').map(&:to_i)

@boost = Intcode.new(input, false)

#part 1
@boost << 1
@boost.run
puts "Test result: #{@boost.output}"

#part 2
@boost.reset
@boost << 2
@boost.run
puts "Coordinates: #{@boost.output}"
