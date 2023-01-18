require_relative '../../lib/aoc_api'

input = File.read(ARGV[0] || AOC.input_file()).strip.split("\n")

#part 1
@sue = []
input.each do |line|
  if line =~ /\ASue (\d+): ((\w+: \d+(, |\z))+)/
    # I 0-index my aunts, TYVM
    index = Regexp.last_match[1].to_i - 1
    data = {}
    Regexp.last_match[2].split(', ').map { |s| s.match(/(\w+): (\d+)/) }.each do |match|
      data[match[1].to_sym] = match[2].to_i
    end
    @sue[index] = data
  else
    raise "Malformed line: #{line}"
  end
end

target = {
  children: 3,
  cats: 7,
  samoyeds: 2,
  pomeranians: 3,
  akitas: 0,
  vizslas: 0,
  goldfish: 5,
  trees: 3,
  cars: 2,
  perfumes: 1,
}

matches = []
@sue.each_with_index do |data, i|
  match = true
  data.each do |type, count|
    if count != target[type]
      match = false
      break
    end
  end
  if match
    matches << i
  end
end

matches.each do |index|
  puts "Exact: Sue #{index + 1} is a match"
end

#part 2
target = {
  children: proc { |val| val == 3 },
  cats: proc { |val| val > 7 },
  samoyeds: proc { |val| val == 2 },
  pomeranians: proc { |val| val < 3 },
  akitas: proc { |val| val == 0 },
  vizslas: proc { |val| val == 0 },
  goldfish: proc { |val| val < 5 },
  trees: proc { |val| val > 3 },
  cars: proc { |val| val == 2 },
  perfumes: proc { |val| val == 1 },
}

matches = []
@sue.each_with_index do |data, i|
  match = true
  data.each do |type, count|
    if not target[type].call(count)
      match = false
      break
    end
  end
  if match
    matches << i
  end
end

matches.each do |index|
  puts "Fuzzy: Sue #{index + 1} is a match"
end


