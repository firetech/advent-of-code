require 'set'
require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@map = Hash.new(false)
@start = nil
lines = File.read(file).rstrip.split("\n")
@end_y = lines.length
lines.each_with_index do |line, y|
  line.each_char.with_index do |char, x|
    case char
    when "S"
      if @start.nil?
        @start = [x, y]
      else
        raise "Multiple starts?"
      end
    when "^"
      @map[[x, y]] = true
    when "."
      # Ignore
    end
  end
end

beams = Set[@start.first]
y = @start.last
@splits = 0  # Part 1
while y < @end_y
  new_beams = beams.flat_map do |x|
    if @map[[x, y]]
      @splits += 1  # Part 1
      [x - 1, x + 1]
    else
      x
    end
  end
  beams = Set.new(new_beams)
  y += 1
end

# Part 1
puts "Number of beam splits: #{@splits}"
