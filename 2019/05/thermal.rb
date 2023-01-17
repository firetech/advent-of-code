require_relative '../../lib/aoc_api'
require_relative '../lib/intcode'

input = File.read(ARGV[0] || AOC.input_file()).split(',').map(&:to_i)

puts "Part 1:"
i = Intcode.new(input)
i.input 1
i.run

puts
puts "Part 2:"
i.reset
i.input 5
i.run
