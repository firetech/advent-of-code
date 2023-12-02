require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

PART1_MAX = {
  'red' => 12,
  'green' => 13,
  'blue' => 14
}

part1_sum = 0
part2_sum = 0
File.read(file).rstrip.split("\n").each do |line|
  case line
  when /\AGame (\d+): (.*)\z/
    id = Regexp.last_match(1).to_i
    part1_possible = true
    part2_minimum = {
      'red' => 0,
      'green' => 0,
      'blue' => 0
    }
    Regexp.last_match(2).split('; ').each do |set|
      set.split(', ').each do |color|
        case color
        when /\A(\d+) (red|green|blue)\z/
          count = Regexp.last_match(1).to_i
          if count > PART1_MAX[Regexp.last_match(2)]
            part1_possible = false
          end
          if count > part2_minimum[Regexp.last_match(2)]
            part2_minimum[Regexp.last_match(2)] = count
          end
        else
          raise "Malformed color: '#{color}'"
        end
      end
    end
    part1_sum += id if part1_possible
    part2_sum += part2_minimum.values.inject(:*)
  else
    raise "Malformed line: '#{line}'"
  end
end

# Part 1
puts "Sum of game IDs possible with 12R, 13G, 14B: #{part1_sum}"

# Part 2
puts "Sum of minimum cube set powers: #{part2_sum}"
