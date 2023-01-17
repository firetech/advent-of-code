require_relative '../../lib/aoc_api'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

input = File.read(file).strip.split("\n")

def parse(line, precedence)
  while line.include?('(')
    line = line.gsub(/\(([^()]+)\)/) { parse(Regexp.last_match(1), precedence) }
  end
  precedence.each do |ops|
    while line =~ / [#{ops}] /
      line = line.sub(/\d+ [#{ops}] \d+/) { |match| eval(match) }
    end
  end
  return line.to_i
end

# Part 1
sum = input.sum { |line| parse(line, ['+*']) }
puts "Sum of results with equal precedence: #{sum}"

# Part 2
sum = input.sum { |line| parse(line, ['+', '*']) }
puts "Sum of results with addition precedence: #{sum}"
