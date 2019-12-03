require 'pp'

input = File.read('input').split("\n").map { |box| box.split('x').map(&:to_i) }

# part 1
areas = input.map do |l, w, h|
  sides = []
  sides << l * w
  sides << l * h
  sides << w * h
  sides.map { |side| side * 2 }.inject(sides.min) { |sum, x| sum + x }
end

puts "#{areas.inject(0) { |sum, x| sum + x }} sqft of paper"

#part 2
lengths = input.map do |l, w, h|
  smallest = [l, w, h].min(2)
  circumference = smallest.inject(l*w*h) { |sum, x| sum + x + x }
end

puts "#{lengths.inject(0) { |sum, x| sum + x }} ft of ribbon"
