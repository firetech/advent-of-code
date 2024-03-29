require_relative '../../lib/aoc'

input = File.read(ARGV[0] || AOC.input_file()).strip

#part 1

puts "Ending floor: #{ input.count('(') - input.count(')') }"

#part 2

floor = 0;
pos = 1;
input.each_char do |c|
  floor += 1 if c == '('
  floor -= 1 if c == ')'
  if floor == -1
    puts "Position: #{pos}"
    break
  end
  pos += 1
end
