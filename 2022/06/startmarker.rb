require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@input = File.read(file).rstrip

def first_uniq_char(length)
  @input.chars.each_cons(length).with_index do |chars, i|
    if chars.uniq.length == length
      return i + length
    end
  end
end

# Part 1
puts "Characters before first start-of-packet marker: #{first_uniq_char(4)}"

# Part 2
puts "Characters before first start-of-message marker: #{first_uniq_char(14)}"
