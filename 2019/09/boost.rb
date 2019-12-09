input = File.read('input').split(',').map(&:to_i)

require_relative '../lib/intcode'

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
