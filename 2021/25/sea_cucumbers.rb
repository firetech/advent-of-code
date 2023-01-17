require 'set'
require_relative '../../lib/aoc_api'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@map = File.read(file).strip.split("\n")
@width = @map.first.length
@height = @map.length
@x_bits = Math.log2(@width).ceil
@x_mask = (1 << @x_bits) - 1

@east_herd = Set[]
@south_herd = Set[]
@map.each_with_index do |line, y|
  line.each_char.with_index do |c, x|
    case c
    when '>'
      @east_herd << (y << @x_bits | x)
    when 'v'
      @south_herd << (y << @x_bits | x)
    when '.'
      # Ignore
    else
      raise "Unexpected character '#{c}'"
    end
  end
end

def step(east_herd, south_herd)
  moved = false
  # Move east-facing herd
  new_east_herd = Set[]
  east_herd.each do |i|
    x = i & @x_mask
    y = i >> @x_bits
    east_i = (y << @x_bits | ((x + 1) % @width))
    if east_herd.include?(east_i) or south_herd.include?(east_i)
      new_east_herd << i
    else
      new_east_herd << east_i
      moved = true
    end
  end
  # Move south-facing herd
  new_south_herd = Set[]
  south_herd.each do |i|
    x = i & @x_mask
    y = i >> @x_bits
    south_i = ((y + 1) % @height << @x_bits | x)
    if new_east_herd.include?(south_i) or south_herd.include?(south_i)
      new_south_herd << i
    else
      new_south_herd << south_i
      moved = true
    end
  end
  return new_east_herd, new_south_herd, moved
end

east_herd = @east_herd
south_herd = @south_herd
steps = 0
begin
  east_herd, south_herd, moved = step(east_herd, south_herd)
  steps += 1
end while moved

puts "Steady state reached at #{steps} steps"
