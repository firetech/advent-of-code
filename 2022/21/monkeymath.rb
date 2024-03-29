require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@monkeys = {}
File.read(file).rstrip.split("\n").each do |line|
  case line
  when /\A(.*): (\d+)\z/
    @monkeys[Regexp.last_match(1).to_sym] = Regexp.last_match(2).to_f
  when /\A(.*): (.*) ([+\-*\/]) (.*)\z/
    @monkeys[Regexp.last_match(1).to_sym] = [
      Regexp.last_match(2).to_sym,
      Regexp.last_match(3).to_sym,
      Regexp.last_match(4).to_sym
    ]
  else
    raise "Malformed line: '#{line}'"
  end
end

def monkey_value(monkey)
  val = @monkeys[monkey]
  case val
  when Array
    return monkey_value(val[0]).send(val[1], monkey_value(val[2]))
  when Float
    return val
  when :humn
    raise TypeError, 'Found humn'
  else
    raise "Unexpected class: #{val.class.name} (#{val.inspect})"
  end
end

# Part 1
root_val = monkey_value(:root)
raise "Rounding error" if root_val.floor != root_val
puts "Root monkey yells #{root_val.floor}"

# Part 2
@monkeys[:humn] = :humn
begin
  value = monkey_value(@monkeys[:root][0])
  equation = @monkeys[:root][2]
rescue TypeError
  value = monkey_value(@monkeys[:root][2])
  equation = @monkeys[:root][0]
end

search_range = 0.0..1e20
min_out = (@monkeys[:humn] = search_range.min; monkey_value(equation))
max_out = (@monkeys[:humn] = search_range.max; monkey_value(equation))
if min_out < value and max_out > value
  check = proc { value <=> monkey_value(equation) }
elsif min_out > value and max_out < value
  check = proc { monkey_value(equation) <=> value }
else
  raise "Output doesn't seem to be linear"
end
humn_val = search_range.bsearch do |i|
  @monkeys[:humn] = i
  check[]
end
raise "Wat." if humn_val.nil?
raise "Rounding error" if humn_val.floor != humn_val
puts "You need to yell #{humn_val.floor}"
