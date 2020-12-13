file = 'input'
#file = 'example1'

input = File.read(file).strip.split("\n")

timestamp = input.shift.to_i
lines = input.shift.split(',').map do |line|
  if line == 'x'
    nil
  else
    line.to_i
  end
end

#part 1
active_lines = lines.compact
min_wait = Float::INFINITY
best_line = nil
active_lines.each do |line|
  wait = line - timestamp % line
  if wait < min_wait
    min_wait = wait
    best_line = line
  end
end

puts "Wait time: #{min_wait}, Line: #{best_line}, Score: #{min_wait * best_line}"


#part 2

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

remainders = []
lines.each_with_index do |line, i|
  if not line.nil?
    remainders << line - i
  end
end

puts "Time of bus cascade: #{chinese_remainder(active_lines, remainders)}"
