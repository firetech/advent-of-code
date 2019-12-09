input = File.read('input').split(',').map(&:to_i)

require_relative '../lib/intcode'

puts "Part 1:"
i = Intcode.new(input)
i.input 1
i.run

puts
puts "Part 2:"
i.reset
i.input 5
i.run
