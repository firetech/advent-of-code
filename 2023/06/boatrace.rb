require_relative '../../lib/aoc'
require_relative '../../lib/aoc_math'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

File.read(file).rstrip.split("\n").each do |line|
  case line
  when /\ATime:\s+((?:\d+(?:\s+|\z))+)/
    @times = Regexp.last_match(1).split(/\s+/).map(&:to_i)
  when /\ADistance:\s+((?:\d+(?:\s+|\z))+)/
    @distances = Regexp.last_match(1).split(/\s+/).map(&:to_i)
  else
    raise "Malformed line: '#{line}'"
  end
end

def race(times, distances)
  prod = 1
  times.zip(distances) do |time, distance|
    # x * (time - x) > distance
    # -x^2 + time*x - distance > 0
    min, max = AOCMath.quadratic_solutions(-1, time, -distance)
    # We need to beat the record, not just touch it.
    min += 1 if min.ceil == min
    max -= 1 if max.ceil == max
    prod *= max.floor - min.ceil + 1
  end
  return prod
end

# Part 1
puts "Product of winning strategies: #{race(@times, @distances)}"

# Part 2
puts "Winning strategies (joined): #{race(
  [@times.map(&:to_s).join.to_i],
  [@distances.map(&:to_s).join.to_i]
)}"
