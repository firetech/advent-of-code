require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

*presents, regions = File.read(file).rstrip.split("\n\n")

@presents = presents.map do |present|
  _, *lines = present.split("\n")
  lines.map { |l| l.count('#') }.sum
end

# This doesn't work for the example, but works fine for the real input
@definitely = 0
@possible = 0
@impossible = 0
regions.split("\n").each do |line|
  case line
  when /\A(\d+)x(\d+):((?:\s+\d+){6})\z/
    width = Regexp.last_match(1).to_i
    height = Regexp.last_match(2).to_i
    counts = Regexp.last_match(3).lstrip.split(/\s+/).map(&:to_i)
    num_presents = counts.sum.to_f
    num_segments = counts.zip(@presents).map { |count, size| count * size }.sum
    if (width / 3) * (height / 3) >= num_presents
      @definitely += 1
    elsif num_segments <= width * height
      @possible += 1
    else
      @impossible += 1
    end
  else
    raise "Malformed line: '#{line}'"
  end
end

puts "Region counts:"
puts "#{@definitely} regions with at least one 3x3 region per present"
puts "#{@possible} regions with less than 3x3 per present, but all segments fitting"
puts "#{@impossible} regions with less space than total segments"
