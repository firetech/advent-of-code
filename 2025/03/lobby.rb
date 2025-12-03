require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

sum = 0
File.read(file).rstrip.split("\n").each do |line|
  case line
  when /\A\d+\z/
    batteries = line.to_i.digits.reverse
    sum += batteries.combination(2).map { |a,b| a*10 + b }.max
  else
    raise "Malformed line: '#{line}'"
  end
end

puts sum
