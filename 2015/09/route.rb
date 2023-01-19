require_relative '../../lib/aoc'

input = File.read(ARGV[0] || AOC.input_file()).strip.split("\n")

#part 1
@distances = {}
input.each do |line|
  if line =~ /\A(\w+) to (\w+) = (\d+)\z/
    from = Regexp.last_match[1]
    to = Regexp.last_match[2]
    dist = Regexp.last_match[3].to_i
    [ from, to ].permutation do |a,b|
      @distances[a] ||= {}
      @distances[a][b] = dist
    end
  else
    raise "Malformed line: #{line}"
  end
end

@totals = @distances.keys.permutation.map do |list|
  length = 0
  list.each_cons(2) do |a,b|
    length += @distances[a][b]
  end
  length
end.sort

puts "Shortest route length: #{@totals.first}"

#part 2
puts "Longest route length: #{@totals.last}"
