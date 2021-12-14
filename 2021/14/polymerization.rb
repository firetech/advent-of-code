file = 'input'
#file = 'example1'

@template, rules_str = File.read(file).strip.split("\n\n")

STEPS = [
  10, # Part 1
  40  # Part 2
]

@rules = {}
rules_str.split("\n").each do |line|
  case line
  when /\A([A-Z]+) -> ([A-Z])\z/
    @rules[Regexp.last_match(1)] = Regexp.last_match(2)
  else
    raise "Malformed line: '#{line}'"
  end
end

pairs = Hash.new(0)
@template.chars.each_cons(2) do |pair|
  pairs[pair.join] += 1
end
STEPS.max.times do |i|
  new = Hash.new(0)
  pairs.each do |pair, count|
    add = @rules[pair]
    if add.nil?
      new[pair] += count
    else
      new[pair[0] + add] += count
      new[add + pair[1]] += count
    end
  end
  pairs = new

  if STEPS.include?(i+1)
    counts = Hash.new(0)
    pairs.each do |pair, count|
      counts[pair[0]] += count
      counts[pair[1]] += count
    end
    # All characters except the first and last are double counted by being
    # included in two pairs (once as first character, once as second character).
    counts[@template[0]] += 1
    counts[@template[-1]] += 1
    values = counts.values
    diff = (values.max / 2) - (values.min / 2)
    puts "Most common - least common after #{i+1} steps: #{diff}"
  end
end

