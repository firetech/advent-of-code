require 'set'
require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()

@input = File.read(file).strip.split("\n").map do |line|
  case line
  when /\A((?:\+|-)\d+)\z/
    Regexp.last_match(1).to_i
  else
    raise "Malformed line: '#{line}'"
  end
end

freq = 0
first_run_result = nil
first_seen_twice = nil
seen = Set[]
while first_seen_twice.nil?
  @input.each do |diff|
    if first_seen_twice.nil?
      if seen.include?(freq)
        first_seen_twice = freq
      else
        seen << freq
      end
    end
    freq += diff
  end
  if first_run_result.nil?
    first_run_result = freq
  end
end

# Part 1
puts "Resulting frequency: #{first_run_result}"

# Part 2
puts "First frequency seen twice: #{first_seen_twice}"
