require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

x = 0
y1 = 0
y2 = 0
@commands = File.read(file).strip.split("\n").map do |line|
  case line
  when /\A(up|down|forward) (\d+)\z/
    n = Regexp.last_match(2).to_i
    case Regexp.last_match(1)
    when 'up'
      y1 -= n
    when 'down'
      y1 += n
    when 'forward'
      x += n
      y2 += y1 * n # y1 is equivalent to aim
    end
  else
    raise "Malformed line: '#{line}'"
  end
end

# Part 1
puts "X/Y movement: #{x} * #{y1} = #{x * y1}"

# Part 2
puts "X/Aim movement: #{x} * #{y2} = #{x * y2}"
