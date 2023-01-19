require_relative '../../lib/aoc'

input = ARGV[0] || AOC.input()
lengths = ARGV.length > 1 ? ARGV[1..-1].map(&:to_i) : [272, 35651584]

#input = '110010110100'; lengths = [12]
#input = '10000'; lengths = [20]

data = input.chars.map { |x| x == '1' }
lengths.each do |length|
  while data.length < length
    data += [false] + data.reverse_each.map { |x| not x }
  end

  checksum = data[0, length]
  begin
    next_checksum = []
    checksum.each_slice(2) do |a,b|
      next_checksum << (a == b)
    end
    checksum = next_checksum
  end while checksum.length % 2 == 0

  checksum_s = checksum.map { |x| (x ? 1 : 0) }.join

  puts "Checksum for #{length} bits of data: #{checksum_s}"
end
