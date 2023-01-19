require_relative '../../lib/aoc'

input = File.read(ARGV[0] || AOC.input_file()).strip
#input = 'X(8x2)(3x3)ABCY'
#input = '(25x3)(3x3)ABC(2x3)XY(5x2)PQRSTX(18x9)(3x2)TWO(5x7)SEVEN'

def unzipped_length(input, recursive = false)
  length = 0
  if input.is_a? String
    input = input.chars
  else
    input = input.clone
  end
  while not input.empty?
    if input.shift == '('
      chars = 0
      while (char = input.shift) != 'x'
        chars = chars * 10 + char.to_i
      end
      repetitions = 0
      while (char = input.shift) != ')'
        repetitions = repetitions * 10 + char.to_i
      end
      block = input.shift(chars)
      if recursive
        length += unzipped_length(block, true) * repetitions
      else
        length += block.length * repetitions
      end
    else
      length += 1
    end
  end
  return length
end

# Part 1
puts "Decompressed length: #{unzipped_length(input)}"

# Part 2
puts "Decompressed length (recursive): #{unzipped_length(input, true)}"
