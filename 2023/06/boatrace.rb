require_relative '../../lib/aoc'

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
    speed = 0
    winning = 0
    1.upto(time-1) do |hold|
      speed += 1
      dist = (time - hold) * speed
      if dist > distance
        winning += 1
      elsif winning > 0
        #break
      end
    end
    prod *= winning
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
