file = ARGV[0] || 'input'
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
    return "(#{monkey_value(val[0])} #{val[1]} #{monkey_value(val[2])})"
  when Integer, Float, Symbol
    return val
  else
    raise 'Ehm?'
  end
end

# Part 1
root_val = eval(monkey_value(:root))
raise "Rounding error" if root_val.floor != root_val
puts "Root monkey yells #{root_val.floor}"

# Part 2
@monkeys[:humn] = :x
val1 = monkey_value(@monkeys[:root][0])
val2 = monkey_value(@monkeys[:root][2])

if val1.include?('x')
  equation = @monkeys[:root][0]
  value = eval(val2)
elsif val2.include?('x')
  value = eval(val1)
  equation = @monkeys[:root][2]
end
search = 0..1e20
min_out = (@monkeys[:humn] = search.min; eval(monkey_value(equation)))
max_out = (@monkeys[:humn] = search.max; eval(monkey_value(equation)))
if min_out < value and max_out > value
  check = proc { value <=> eval(monkey_value(equation)) }
elsif min_out > value and max_out < value
  check = proc { eval(monkey_value(equation)) <=> value }
else
  raise "Output doesn't seem to be linear"
end
humn_val = (0..1e20).bsearch do |i|
  @monkeys[:humn] = i
  check[]
end
raise "Wat." if humn_val.nil?
raise "Rounding error" if humn_val.floor != humn_val
puts "You need to yell #{humn_val.floor}"
