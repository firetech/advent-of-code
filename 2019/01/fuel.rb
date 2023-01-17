require_relative '../../lib/aoc_api'

input = File.read(ARGV[0] || AOC.input_file()).strip.split("\n").map(&:to_i)

#part 1
def fuel(weight)
  return [weight.to_i / 3 - 2, 0].max
end

puts "Total fuel: #{input.map { |weight| fuel(weight) }.sum}"


#part 2
def all_fuel(weight)
  sum = 0
  begin
    weight = fuel(weight)
    sum += weight
  end while weight > 0
  return sum
end
puts "Actual total fuel: #{input.map { |weight| all_fuel(weight) }.sum}"
