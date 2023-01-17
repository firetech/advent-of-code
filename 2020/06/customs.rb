require 'set'
require_relative '../../lib/aoc_api'

input = File.read(ARGV[0] || AOC.input_file()).strip
#input = File.read('example1').strip

groups = input.split("\n\n").map { |group| group.split("\n").map(&:chars) }

count_any = 0 #part 1
count_all = 0 #part 2
groups.each do |group|
  questions_any = Set.new #part 1
  questions_all = Set.new('a'..'z') #part 2
  group.each do |answers|
    questions_any += answers #part 1
    questions_all &= answers #part 2
  end
  count_any += questions_any.length #part 1
  count_all += questions_all.length #part 2
end
puts "Sum of any-yes questions: #{count_any}" #part 1
puts "Sum of all-yes questions: #{count_all}" #part 2
