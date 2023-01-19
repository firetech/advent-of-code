require_relative '../../lib/aoc'

input = File.read(ARGV[0] || AOC.input_file()).strip.split("\n").map(&:to_i)
preamble_size = (ARGV[1] || 25).to_i

#input = File.read('example1').strip.split("\n").map(&:to_i); preamble_size = 5

#part 1
prev_buf = []
waiting_buf = input.clone
preamble_size.times { prev_buf << waiting_buf.shift }
found = true
target = nil
while found
  found = false
  target = waiting_buf.shift
  prev_buf.combination(2) do |a,b|
    if a + b == target
      found = true
      break
    end
  end
  prev_buf.shift
  prev_buf << target
end
puts "First non-matching number: #{target}"

#part 2
input.each_with_index do |val, i|
  first_i = i
  while val < target
    i += 1
    val += input[i]
  end
  if val == target
    numbers = input[first_i..i]
    puts "Encryption weakness: #{numbers.min + numbers.max}"
    break
  end
end
