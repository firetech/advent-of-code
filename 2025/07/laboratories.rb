require 'set'
require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@beams = Hash.new(0)
@splits = 0  # Part 1
File.read(file).rstrip.split("\n").each_with_index do |line, y|
  new_beams = Hash.new(0)
  line.each_char.with_index do |char, x|
    case char
    when "S"
      new_beams[x] += 1
    when "^"
      if @beams[x] > 0
        @splits += 1  # Part 1
        new_beams[x-1] += @beams[x]
        new_beams[x+1] += @beams[x]
      end
    when "."
      new_beams[x] += @beams[x]
    else
      raise "Unexpected map char '#{char}'."
    end
  end
  @beams = new_beams
end

# Part 1
puts "Number of beam splits: #{@splits}"

# Part 2
puts "Number of timelines: #{@beams.values.sum}"
