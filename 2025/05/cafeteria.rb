require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

ranges, ingredients = File.read(file).rstrip.split("\n\n")

@ranges = []
ranges.split("\n").each do |line|
  case line
  when /\A(\d+)-(\d+)\z/
    @ranges << {
      min: Regexp.last_match(1).to_i,
      max: Regexp.last_match(2).to_i
    }
  else
    raise "Malformed line: '#{line}'"
  end
end

# Part 1
fresh = 0
ingredients.split("\n").each do |line|
  case line
  when /\A\d+\z/
    fresh += 1 if @ranges.any? { |r| line.to_i.between?(r[:min], r[:max]) }
  else
    raise "Malformed line: '#{line}'"
  end
end
puts "Fresh ingredients: #{fresh}"

# Part 2
@merged_ranges = []
last_range = nil
@ranges.sort_by { |r| r[:min] }.each do |r|
  if not last_range.nil? and last_range[:max] >= r[:min]
    last_range[:max] = [last_range[:max], r[:max]].max
  else
    @merged_ranges << r
    last_range = r
  end
end
merged_total = @merged_ranges.sum { |r| r[:max] - r[:min] + 1 }
puts "Total possible fresh ingredients: #{merged_total}"

