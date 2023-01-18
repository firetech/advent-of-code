require_relative '../../lib/aoc_api'

input = File.read(ARGV[0] || AOC.input_file()).strip.split("\n")
#input = File.read('example').strip.split("\n")

AMOUNT = 150
#AMOUNT = 25

#part 1
@containers = input.map(&:to_i)

def pour(containers, remaining, included = [])
  if remaining == 0
    return [included]
  elsif remaining < 0
    return []
  end
  combinations = []
  containers.each_with_index do |container, i|
    rest = []
    if i < containers.length - 1
      rest += containers[(i+1)..-1]
    end
    combinations += pour(rest, remaining - container, included + [container])
  end
  return combinations
end

combinations = pour(@containers, AMOUNT)
puts "#{combinations.count} ways to fill."

#part 2
min_containers = combinations.map(&:count).min
min_combinations = combinations.select { |containers| containers.count == min_containers }
puts "#{min_combinations.count} ways to fill with #{min_containers} containers"
