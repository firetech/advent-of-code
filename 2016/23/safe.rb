require_relative '../../lib/aoc'
require_relative '../lib/assembunny'

file = ARGV[0] || AOC.input_file()
inputs = ARGV.length > 1 ? ARGV[1..-1].map(&:to_i) : [7, 12]
#file = 'example1'; inputs = [0]

assembunny = AssemBunny.new(file)

inputs.each do |eggs|
  puts "Value to safe (input #{eggs}): #{assembunny.run(a: eggs)[:a]}"
end
