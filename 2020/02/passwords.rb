require_relative '../../lib/aoc_api'

input = File.read(ARGV[0] || AOC.input_file()).strip.split("\n")
#input = File.read('example1').strip.split("\n")

#part 1
valid = 0
input.each do |line|
  if line =~ /\A(\d+)-(\d+) (\w): (\w+)\z/
    _, min, max, char, password = Regexp.last_match.to_a
    if (min.to_i..max.to_i).include?(password.count(char))
      valid += 1
    end
  else
    raise "Invalid line: '#{line}'"
  end
end
puts "Part 1: #{valid} passwords are valid"


#part 2
valid = 0
input.each do |line|
  if line =~ /\A(\d+)-(\d+) (\w): (\w+)\z/
    _, pos1, pos2, char, password = Regexp.last_match.to_a
    if (password[pos1.to_i - 1] == char) ^ (password[pos2.to_i - 1] == char)
      valid += 1
    end
  else
    raise "Invalid line: '#{line}'"
  end
end
puts "Part 2: #{valid} passwords are valid"
