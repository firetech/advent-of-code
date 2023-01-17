require_relative '../../lib/aoc_api'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@crabs = File.read(file).strip.split(',').map(&:to_i)

fuels = @crabs.min.upto(@crabs.max).map do |pos|
  [
    @crabs.sum { |c| (c - pos).abs },                # Part 1
    @crabs.sum { |c| n = (c - pos).abs; n*(n+1)/2 }  # Part 2
  ]
end

# Part 1
puts "Minimum fuel required (1 fuel per step): #{fuels.map(&:first).min}"

# Part 2
puts "Minimum fuel required (N fuel per step): #{fuels.map(&:last).min}"
