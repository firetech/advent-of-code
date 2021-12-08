require 'set'

file = 'input'
#file = 'example1'
#file = 'example2'

def char_sets(str_list)
  str_list.map { |str| Set.new(str.chars) }
end

@input = File.read(file).strip.split("\n").map do |line|
  case line
  when /\A([a-g]+ )+\|( [a-g]+)+\z/
    patterns, output = line.split(' | ')
    [ char_sets(patterns.split(' ')), char_sets(output.split(' ')) ]
  else
    raise "Malformed line: '#{line}'"
  end
end

# Part 1
easy_outputs = @input.sum do |_, output|
  output.count { |num| [2, 3, 4, 7].include?(num.length) }
end
puts "Appearances of 1, 4, 7 and 8 in outputs: #{easy_outputs}"

# Part 2
output_sum = @input.sum do |patterns, output|
  map = {}
  fives = Set[]
  sixes = Set[]
  patterns.each do |pat|
    case pat.length
    when 2
      map[pat] = 1
    when 3
      map[pat] = 7
    when 4
      map[pat] = 4
    when 7
      map[pat] = 8
    when 5
      fives << pat
    when 6
      sixes << pat
    end
  end
  one = map.key(1)
  # Find the 3, giving the horizontal segments
  three = fives.find { |pat| one.subset?(pat) }
  map[three] = 3
  fives.delete(three)
  horizontals = three - one
  # Sort the six-segment numbers (0, 6, 9)
  zero = sixes.find { |pat| not horizontals.subset?(pat) }
  map[zero] = 0
  sixes.delete(zero)
  six = sixes.find { |pat| not one.subset?(pat) }
  map[six] = 6
  sixes.delete(six)
  raise "Not three six-segment numbers?" if sixes.length != 1
  nine = sixes.first
  map[nine] = 9
  # Find 5 and 2
  two = fives.find { |pat| ((pat & nine) - three).empty? }
  map[two] = 2
  fives.delete(two)
  raise "Not three five-segment numbers?" if fives.length != 1
  five = fives.first
  map[five] = 5

  # Calculate the intended output number
  output.inject(0) { |num, pat| num * 10 + map[pat] }
end

puts "Sum of output numbers: #{output_sum}"
