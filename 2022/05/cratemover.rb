require_relative '../../lib/aoc_api'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

stacks, instructions = File.read(file).rstrip.split("\n\n", 2)

@stacks = []
stacks.split("\n")[0..-2].each do |line|
  line.scan(/(?:\[([A-Z])\]|   )(?: |\Z)/).each_with_index do |(crate), i|
    @stacks[i] ||= []
    next if crate.nil?
    @stacks[i].unshift(crate)
  end
end

s1 = @stacks.map(&:clone) # Part 1
s2 = @stacks.map(&:clone) # Part 2
instructions.split("\n").each do |line|
  case line
  when /\Amove (\d+) from (\d+) to (\d+)\z/
    count = Regexp.last_match(1).to_i
    from = Regexp.last_match(2).to_i - 1
    to = Regexp.last_match(3).to_i - 1

    # Part 1
    s1[to].push(*s1[from].pop(count).reverse)

    # Part 2
    s2[to].push(*s2[from].pop(count))
  else
    raise "Malformed line: '#{line}'"
  end
end

# Part 1
puts "Stack tops when moving individual crates: #{s1.map(&:last).join}"

# Part 2
puts "Stack tops when moving groups of crates: #{s2.map(&:last).join}"
