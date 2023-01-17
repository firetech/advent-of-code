require_relative '../../lib/aoc_api'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

# Graciously stolen from https://rosettacode.org/wiki/Chinese_remainder_theorem#Ruby
def extended_gcd(a, b)
  last_remainder, remainder = a.abs, b.abs
  x, last_x, y, last_y = 0, 1, 1, 0
  while remainder != 0
    last_remainder, (quotient, remainder) = remainder, last_remainder.divmod(remainder)
    x, last_x = last_x - quotient*x, x
    y, last_y = last_y - quotient*y, y
  end
  return last_remainder, last_x * (a < 0 ? -1 : 1)
end
def invmod(e, et)
  g, x = extended_gcd(e, et)
  if g != 1
    raise 'Multiplicative inverse modulo does not exist!'
  end
  x % et
end
def chinese_remainder(mods, remainders)
  max = mods.inject( :* )  # product of all moduli
  series = remainders.zip(mods).map{ |r,m| (r * max * invmod(max/m, m) / m) }
  series.inject( :+ ) % max
end

mods = []
remainders = []
File.read(file).strip.split("\n").each do |line|
  if line =~ /\ADisc #(\d+) has (\d+) positions; at time=0, it is at position (\d+).\z/
    disc = Regexp.last_match(1).to_i
    positions = Regexp.last_match(2).to_i
    start = Regexp.last_match(3).to_i
    mods << positions
    remainders << (positions - start - disc) % positions
  else
    raise "Malformed line: '#{line}'"
  end
end

# Part 1
puts "Press button at time=#{chinese_remainder(mods, remainders)}"

# Part 2
mods << 11
remainders << (11 - mods.length) % 11
puts "With added disc, press button at time=#{chinese_remainder(mods, remainders)}"
