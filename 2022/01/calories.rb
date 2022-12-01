file = ARGV[0] || 'input'
#file = 'example1'

@elves = File.read(file).strip.split("\n\n").map do |group|
  group.split("\n").map(&:to_i).sum
end

# Part 1
puts "Top elf is carrying #{@elves.max} Calories"

# Part 2
puts "Top three elves are carrying #{@elves.sort.last(3).flatten.sum} Calories"
