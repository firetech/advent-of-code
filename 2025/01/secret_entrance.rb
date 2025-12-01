require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'
#file = 'example2'

dial = 50
@zeroes = 0  # Part 1
@passes = 0  # Part 2
File.read(file).rstrip.split("\n").each do |line|
  case line
  when /\A(L|R)(\d+)\z/
    move = Regexp.last_match(2).to_i
    @passes += move / 100
    if Regexp.last_match(1) == 'R'
      new_dial = (dial + move) % 100
      @passes += 1 if new_dial < dial  # Part 2
    else
      new_dial = (dial - move) % 100
      @passes += 1 if (new_dial == 0 or new_dial > dial) and dial != 0  # Part 2
    end
    dial = new_dial
    @zeroes += 1 if dial == 0  # Part 1
  else
    raise "Malformed line: '#{line}'"
  end
end

# Part 1
puts "Times stopping at 0: #{@zeroes}"

# Part 2
puts "Times passing 0: #{@passes}"
