require_relative '../../lib/aoc'

input = File.read(ARGV[0] || AOC.input_file()).strip.split("\n")

#part 1
def is_nice(str)
  if str.count('aeiou') < 3
    return false
  end
  if not str =~ /(.)\1/
    return false
  end
  if str =~ /ab|cd|pq|xy/
    return false
  end
  return true
end

puts "#{input.select { |str| is_nice(str) }.count} nice strings"

#part 2
def is_nice2(str)
  if not str =~ /(..).*\1/
    return false
  end
  if not str =~ /(.).\1/
    return false
  end
  return true
end

puts "#{input.select { |str| is_nice2(str) }.count} nice strings (v2)"

