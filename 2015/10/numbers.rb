require_relative '../../lib/aoc_api'

input = (ARGV[0] || AOC.input()).to_i
#input = 1

def numberwang(input, iterations)
  x = input.to_s
  iterations.times do
    x.gsub!(/(.)\1*/) do |rep|
      "#{rep.length}#{rep[0]}"
    end
  end
  return x
end

#part 1
x = numberwang(input, 40)
puts "Length after 40 iterations: #{x.length}"

#part 2
x = numberwang(x, 10)
puts "Length after 50 iterations: #{x.length}"
