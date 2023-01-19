require_relative '../../lib/aoc'

input = File.read(ARGV[0] || AOC.input_file()).strip
#input = File.read('example').strip

#part 1
require 'set'
input_map, input_str = input.split("\n\n")

@map = {}
input_map.split("\n").each do |line|
  if line =~ /\A(\w+) => (\w+)\z/
    @map[Regexp.last_match[1]] ||= []
    @map[Regexp.last_match[1]] << Regexp.last_match[2]
  else
    raise "Malformed line: #{line}"
  end
end

results = Set.new
@map.each do |from, to_list|
  parts = input_str.split(/(?=#{Regexp.escape(from)})/)
  to_list.each do |to|
    parts.each_with_index do |part, i|
      if not part.start_with? from
        next
      end
      results << "#{parts[0...i].join}#{part.sub(from, to)}#{parts[(i+1)..-1].join}"
    end
  end
end

puts "#{results.length} distinct molecules found"

#part 2
# Assumes quite a lot about the input and doesn't work in the general case.
# My first thought, a BFS, was a bit too slow...
def replace(base, from, to, pos)
  "#{base[0...pos]}#{to}#{base[(pos + from.length)..-1]}"
end

molecule = input_str
steps = 0
while molecule != 'e'
  @map.each do |from, to_list|
    to_list.each do |to|
      pos = molecule.rindex(to)
      if not pos.nil?
        molecule = replace(molecule, to, from, pos)
        steps += 1
      end
    end
  end
end
puts "#{steps} steps from e to #{input_str}"
