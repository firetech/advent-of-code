require_relative '../../lib/aoc'

input = File.read(ARGV[0] || AOC.input_file()).split("\n").map do |box|
  box.split('x').map(&:to_i)
end

# Part 1
areas = input.map do |l, w, h|
  sides = []
  sides << l * w
  sides << l * h
  sides << w * h
  sides.map { |side| side * 2 }.sum(sides.min)
end

puts "#{areas.sum} sqft of paper"

# Part 2
lengths = input.map do |l, w, h|
  smallest = [l, w, h].min(2)
  circumference = smallest.sum(l*w*h) { |x| x + x }
end

puts "#{lengths.sum} ft of ribbon"
