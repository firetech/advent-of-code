require_relative '../../lib/aoc'

input = (ARGV[0] || AOC.input()).to_i
#input = 5

# Part 1 (see end of https://www.youtube.com/watch?v=uCsD3ZGzMgE)
input_2 = input.to_s(2).chars
winner = (input_2[1..-1] + [input_2.first]).join.to_i(2)
puts "Winning elf (next to): #{winner}"

# Part 2
split = input / 2 + 1
left = (1..split-1).to_a
right = (split..input).to_a.reverse
while not left.empty? and not right.empty?
  if left.length > right.length
    left.pop
  else
    right.pop
  end

  right.unshift(left.shift)
  left << right.pop
end
puts "Winning elf (across): #{left.first}"
