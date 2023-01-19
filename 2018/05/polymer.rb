require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

input = File.read(file).strip

CASE_DIFF = ('a'.ord - 'A'.ord).abs

def react(polymer)
  result = []
  polymer.each_char do |c|
    if result.empty? or (result.last.ord - c.ord).abs != CASE_DIFF
      result << c
    else
      result.pop
    end
  end
  return result.join
end

# Part 1
result = react(input)
units = result.length
puts "Units after full reaction: #{units}"

# Part 2
# Running this on the reaction from Part 1 instead of the full input seems to
# give the same result, in about a quarter of the time.
best = units
char = nil
('a'..'z').each do |c|
  check = react(result.gsub(/#{c}/i, '')).length
  if check < best
    char = c
    best = check
  end
end
puts "Units after removing '#{char}' and continued reaction: #{best}"
