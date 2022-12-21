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
    monkey_value(val[0]).send(val[1], monkey_value(val[2]))
  when Float, Z3::IntExpr
    return val
  else
    raise "Unexpected class: #{val.class.name}"
  end
end

# Part 1
root_val = monkey_value(:root)
raise "Rounding error" if root_val.floor != root_val
puts "Root monkey yells #{root_val.floor}"

# Part 2
require 'z3'
@solver = Z3::Solver.new
@monkeys[:humn] = Z3.Int('humn')
@monkeys[:root][1] = :==
@solver.assert monkey_value(:root)
raise 'Unsolvable?!' unless @solver.satisfiable?
puts "You need to yell #{@solver.model[@monkeys[:humn]]}"
