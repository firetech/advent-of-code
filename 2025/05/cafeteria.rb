require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

ranges, ingredients = File.read(file).rstrip.split("\n\n")

@ranges = []
ranges.split("\n").each do |line|
  case line
  when /\A(\d+)-(\d+)\z/
    @ranges << [Regexp.last_match(1).to_i, Regexp.last_match(2).to_i]
  else
    raise "Malformed line: '#{line}'"
  end
end

# Part 1
fresh = 0
ingredients.split("\n").each do |line|
  case line
  when /\A\d+\z/
    fresh += 1 if @ranges.any? { |r| line.to_i.between?(r.first, r.last) }
  else
    raise "Malformed line: '#{line}'"
  end
end
puts "Fresh ingredients: #{fresh}"

# Part 2
# Filter out ranges completely covered by another
good_ranges = @ranges.uniq
good_ranges = good_ranges.filter { |r| not good_ranges.any? { |rr| rr != r and rr.first <= r.first and rr.last >= r.last }}.sort_by(&:first)

# Merge the rest
@merged_ranges = [good_ranges.shift]
last_range = @merged_ranges.first
good_ranges.each do |r|
  if last_range.last >= r.first
    last_range[1] = r.last
  else
    @merged_ranges << r
    last_range = r
  end
end
merged_total = @merged_ranges.sum { |r| r.last - r.first + 1 }
puts "Total possible fresh ingredients: #{merged_total}"

