require_relative '../../lib/aoc_api'

file = ARGV[0] || AOC.input_file()
#file = 'example1'
#file = 'example2'

x = 1
@x = [x] + File.read(file).rstrip.split("\n").flat_map do |line|
  case line
  when /\Anoop\z/
    [x]
  when /\Aaddx (-?\d+)\z/
    [x, x += Regexp.last_match(1).to_i]
  else
    raise "Malformed line: '#{line}'"
  end
end

# Part 1
strength_sum = [20, 60, 100, 140, 180, 220].map { |c| @x[c-1] * c }.sum
puts "Sum of interesting signal strengths: #{strength_sum}"

# Part 2
screen = @x.map.with_index { |x, i| ((x - (i % 40)).abs <= 1) ? "\u2588" : ' ' }
screen.pop # Contains more value than needed
screen.each_slice(40) { |line| puts line.join }
