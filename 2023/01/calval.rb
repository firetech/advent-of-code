require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'
#file = 'example2'

# Part 1
sum = 0
File.read(file).rstrip.split("\n").each do |line|
  first_digit_match = /\A\D*(\d)/.match(line)
  last_digit_match = /(\d)\D*\z/.match(line)
  sum += first_digit_match[1].to_i * 10 + last_digit_match[1].to_i
end
puts "Sum of calibration values (digits only): #{sum}"

# Part 2
def to_digit(x)
  case x
  when /\A\d\z/
    return x.to_i
  when 'one'
    return 1
  when 'two'
    return 2
  when 'three'
    return 3
  when 'four'
    return 4
  when 'five'
    return 5
  when 'six'
    return 6
  when 'seven'
    return 7
  when 'eight'
    return 8
  when 'nine'
    return 9
  end
end

sum2 = 0
File.read(file).rstrip.split("\n").each do |line|
  first_digit_match = /\A.*?(\d|one|two|three|four|five|six|seven|eight|nine).*\z/.match(line)
  last_digit_match = /\A.*(\d|one|two|three|four|five|six|seven|eight|nine).*?\z/.match(line)
  sum2 += to_digit(first_digit_match[1]) * 10 + to_digit(last_digit_match[1])
end
puts "Sum of calibration values (including lettered digits): #{sum2}"
