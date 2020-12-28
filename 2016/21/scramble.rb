file = 'input'; part1_str = 'abcdefgh'; part2_str = 'fbgdceah'
#file = 'example1'; part1_str = 'abcde'; part2_str = 'decab'

input = File.read(file).strip.split("\n").map do |line|
  case line
  when /\Aswap position (\d+) with position (\d+)\z/
    [:swap, Regexp.last_match(1).to_i, Regexp.last_match(2).to_i]
  when /\Aswap letter ([[:lower:]]) with letter ([[:lower:]])\z/
    [:swap, Regexp.last_match(1), Regexp.last_match(2)]
  when /\Arotate (left|right) (\d+) steps?\z/
    [:rotate, Regexp.last_match(2).to_i * (Regexp.last_match(1) == 'right' ? -1 : 1)]
  when /\Arotate based on position of letter ([[:lower:]])\z/
    [:rotate, Regexp.last_match(1)]
  when /\Areverse positions (\d+) through (\d+)\z/
    [:reverse, Regexp.last_match(1).to_i, Regexp.last_match(2).to_i]
  when /\Amove position (\d+) to position (\d+)\z/
    [:move, Regexp.last_match(1).to_i, Regexp.last_match(2).to_i]
  else
    raise "Malformed line: '#{line}'"
  end
end

def scramble(instructions, str, undo = false)
  str = str.chars
  if undo
    instructions = instructions.reverse
  end
  instructions.each do |instr, arg1, arg2|
    case instr
    when :swap
      # Undo == Do
      if arg1.is_a? String
        arg1 = str.index(arg1)
      end
      if arg2.is_a? String
        arg2 = str.index(arg2)
      end
      str[arg1], str[arg2] = str[arg2], str[arg1]
    when :rotate
      if arg1.is_a? String
        arg1 = str.index(arg1)
        if undo
          # pos shift after
          #   0     1     1
          #   1     2     3
          #   2     3     5
          #   3     4     7
          #   4     6     2
          #   5     7     4
          #   6   8/0     6
          #   7   9/1     0
          arg1 = arg1/2 + ((arg1 % 2 == 1 or arg1 == 0) ? 1 : 5)
        else
          arg1 = -(1 + arg1 + (arg1 >= 4 ? 1 : 0))
        end
      elsif undo
        arg1 = -arg1
      end
      str.rotate!(arg1)
    when :reverse
      # Undo == Do
      str[arg1..arg2] = str[arg1..arg2].reverse
    when :move
      if undo
        arg1, arg2 = arg2, arg1
      end
      str.insert(arg2, str.delete_at(arg1))
    else
      raise "Unknown instruction: '#{instr}'"
    end
  end
  return str.join
end

# Part 1
part1_scramble = scramble(input, part1_str)
puts "Scramble result: #{part1_scramble}"

# Part 2
if scramble(input, part1_scramble, true) != part1_str
  raise "Unscramble seems to be faulty"
end
puts "Unscramble result: #{scramble(input, part2_str, true)}"
