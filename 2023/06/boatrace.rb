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
    minimum = nil
    maximum = nil
    1.upto(time-1) do |hold|
      speed += 1
      dist = (time - hold) * speed
      if dist > distance
        minimum = hold
        break
      end
    end
    speed = time
    (time-1).downto(1) do |hold|
      speed -= 1
      dist = (time - hold) * speed
      if dist > distance
        maximum = hold
        break
      end
    end
    prod *= maximum - minimum + 1
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
