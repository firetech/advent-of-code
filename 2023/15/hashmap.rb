require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

def holiday_ascii_string_helper(str) # hash() was already in use...
  val = 0
  str.each_char do |chr|
    val += chr.ord
    val *= 17
    val &= 255 # % 256 == & 255
  end
  return val
end

part1_sum = 0 # Part 1
boxes = Array.new(256) { {} } # Hashes are ordered in Ruby :)
File.read(file).rstrip.split("\n").join.split(',') do |step|
  full_hash = holiday_ascii_string_helper(step)
  part1_sum += full_hash # Part 1

  # Part 2
  case step
  when /\A(.*)=(\d+)\z/
    label = Regexp.last_match(1)
    focal = Regexp.last_match(2).to_i
    boxes[holiday_ascii_string_helper(label)][label] = focal
  when /\A(.*)-\z/
    label = Regexp.last_match(1)
    boxes[holiday_ascii_string_helper(label)].delete(label)
  else
    raise "Malformed label: '#{label}'"
  end
end

# Part 1
puts "Sum of all HASH values: #{part1_sum}"

# Part 2
focusing_power = 0
boxes.each_with_index do |content, box|
  box_power = 0
  content.each.with_index do |(label, focal), slot|
    box_power += focal * (slot + 1)
  end
  focusing_power += (box + 1) * box_power
end
puts "Focusing power: #{focusing_power}"
