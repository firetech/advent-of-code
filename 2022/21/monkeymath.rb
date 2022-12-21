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
  when Float, Symbol
    return val
  else
    raise 'Ehm?'
  end
end

root_val = eval(monkey_value(:root))
raise "Rounding error" if root_val.floor != root_val
puts "Root monkey yells #{root_val.floor}"

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
humn_val = (0..1e20).bsearch do |i|
  @monkeys[:humn] = i
  eval(monkey_value(equation)) <=> value
end
if humn_val.nil?
  # Try other direction, bsearch requires its outputs to be ordered positive
  # before zero before negative to work.
  humn_val = (0..1e20).bsearch do |i|
    @monkeys[:humn] = i
    value <=> eval(monkey_value(equation))
  end
  raise "Wat." if humn_val.nil?
end
raise "Rounding error" if humn_val.floor != humn_val
puts "You need to yell #{humn_val.floor}"
