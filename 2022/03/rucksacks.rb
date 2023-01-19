require 'set'
require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@rucksacks = []
File.read(file).strip.split("\n").each do |line|
  case line
  when /\A([a-zA-Z]+)\z/
    @rucksacks << line
  else
    raise "Malformed line: '#{line}'"
  end
end

def prio(item)
  case item
  when 'a'..'z'
    return item.ord - 'a'.ord + 1
  when 'A'..'Z'
    return item.ord - 'A'.ord + 27
  end
end

# Part 1
ind_sum = 0
@rucksacks.each do |content|
  x, y = content.chars.each_slice(content.length / 2).map(&:to_set)
  ind_sum += prio((x & y).first)
end

puts "Sum of priorities of items in both compartments: #{ind_sum}"

# Part 2
group_sum = 0
@rucksacks.each_slice(3) do |contents|
  in_all = contents.inject(nil) do |set, content|
    content_set = content.chars.to_set
    if set.nil?
      content_set
    else
      set & content_set
    end
  end
  group_sum += prio(in_all.first)
end

puts "Sum of priorities of common items in each group: #{group_sum}"
