require_relative '../../lib/aoc_api'

input = File.read(ARGV[0] || AOC.input_file()).strip
#input = '{"a":{"b":4},"c":-1}'

#part 1
sum = 0
input.scan(/-?\d+/).each do |num|
  sum += num.to_i
end

puts "Sum: #{sum}"

#part 2
require 'json'
json = JSON.parse(input)
def traverse(o)
  case o
  when Integer
    return o
  when String
    #ignore
  when Array
    sum = 0
    o.each { |x| sum += traverse(x) }
    return sum
  when Hash
    values = o.values
    if not values.include? 'red'
      return traverse(values)
    end
  end
  return 0
end

puts "Unred sum: #{traverse(json)}"
