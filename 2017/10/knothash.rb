require_relative '../../lib/aoc_api'

input = File.read(ARGV[0] || AOC.input_file()).strip
@max = 255

#input = '3,4,1,5'; @max = 4
#input = ''; @max = 255
#input = 'AoC 2017'; @max = 255
#input = '1,2,3'; @max = 255
#input = '1,2,4'; @max = 255

def knothash(lengths, rounds = 1)
  current = 0
  skip = 0
  list = (0..@max).to_a

  rounds.times do
    lengths.each do |length|
      list[0, length] = list[0, length].reverse
      list.rotate!(length + skip)
      current = (current + length + skip) % list.length
      skip += 1
    end
  end

  return list.rotate(-current)
end

# Part 1
list = knothash(input.split(',').map(&:to_i))
puts "Product of first two numbers: #{list[0] * list[1]}"

# Part 2
list = knothash(input.bytes + [17, 31, 73, 47, 23], 64)
parts = list.each_slice(16).map { |slice| slice.inject(&:^) }
puts "Hash: #{parts.map { |p| '%02x' % p }.join}"
