require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

*presents, regions = File.read(file).rstrip.split("\n\n")

@presents = presents.map do |present|
  _, *lines = present.split("\n")
  lines.map { |l| l.count('#') }.sum
end

# This doesn't work for the example, but works fine for the real input
@working = 0
regions.split("\n").each do |line|
  case line
  when /\A(\d+)x(\d+):((?:\s+\d+){6})\z/
    width = Regexp.last_match(1).to_i
    height = Regexp.last_match(2).to_i
    counts = Regexp.last_match(3).lstrip.split(/\s+/).map(&:to_i)
    total = counts.zip(@presents).map { |count, size| count * size }.sum
    @working += 1 if total <= width * height
  else
    raise "Malformed line: '#{line}'"
  end
end

puts "Regions fitting all listed presents: #{@working}"
