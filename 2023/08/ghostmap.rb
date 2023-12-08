require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'
#file = 'example2'
#file = 'example3'

@directions, map = File.read(file).rstrip.split("\n\n")
@map = {}
map.split("\n").each do |line|
  case line
  when /\A(\S{3}) = \((\S{3}), (\S{3})\)\z/
    @map[Regexp.last_match(1)] = {
      'L' => Regexp.last_match(2),
      'R' => Regexp.last_match(3)
    }
  else
    raise "Malformed line: '#{line}'"
  end
end

# Part 1
if @map.has_key?('AAA') and @map.has_key?('ZZZ') # For example3
  step = 0
  pos = 'AAA'
  until pos == 'ZZZ'
    pos = @map[pos][@directions[step % @directions.length]]
    raise 'Ehm?' if pos.nil?
    step += 1
  end
  puts "Steps to ZZZ: #{step}"
end

# Part 2
step = 0
pos = @map.keys.select { |p| p.end_with?('A') }
cycle = [nil] * pos.length
while cycle.include?(nil)
  pos.map!.with_index do |p, i|
    next unless cycle[i].nil?
    new_pos = @map[p][@directions[step % @directions.length]]
    raise 'Ehm?' if new_pos.nil?
    if new_pos.end_with?('Z')
      if cycle[i].nil?
        cycle[i] = step + 1
      end
    end
    new_pos
  end
  step += 1
end
puts "Steps to all ??Z: #{cycle.inject(&:lcm)}"
