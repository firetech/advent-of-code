require_relative '../../lib/aoc_api'

input = File.read(ARGV[0] || AOC.input_file()).strip.split("\n")

#part 1
@wires = {}
input.each do |line|
  case line
  when /\A(\d+|[a-z]+) -> ([a-z]+)\z/
    @wires[Regexp.last_match[2]] = Regexp.last_match[1]
  when /\A(\d+|[a-z]+) (AND|OR|RSHIFT|LSHIFT) (\d+|[a-z]+) -> ([a-z]+)\z/
    @wires[Regexp.last_match[4]] = [Regexp.last_match[2].downcase.to_sym,
                                   Regexp.last_match[1],
                                   Regexp.last_match[3]]
  when /\A(NOT) (\d+|[a-z]+) -> ([a-z]+)\z/
    @wires[Regexp.last_match[3]] = [Regexp.last_match[1].downcase.to_sym,
                                   Regexp.last_match[2]]
  else
    raise "Unknown line: #{line}"
  end
end

def calculate(wires, wire)
  val = wires[wire]
  case val
  when Integer
    return val
  when Array
    val = do_op(wires, *val)
  else
    val = parse(wires, val)
  end
  wires[wire] = val
  return val
end

def parse(wires, val)
  case val
  when /\A\d+\z/
    val = val.to_i
  when /\A[a-z]+\z/
    val = calculate(wires, val)
  else
    raise "Unknown value: #{val}"
  end
end

def do_op(wires, op, arg1, arg2 = nil)
  case op
  when :and
    (parse(wires, arg1) & parse(wires, arg2)) & 0xFFFF
  when :or
    (parse(wires, arg1) | parse(wires, arg2)) & 0xFFFF
  when :rshift
    (parse(wires, arg1) >> parse(wires, arg2)) & 0xFFFF
  when :lshift
    (parse(wires, arg1) << parse(wires, arg2)) & 0xFFFF
  when :not
    ~parse(wires, arg1) & 0xFFFF
  end
end

a_val = calculate(@wires.clone, 'a')
puts "Signal on wire a: #{a_val}"

#part 2
wires2 = @wires.clone
wires2['b'] = a_val
puts "Signal on wire a, round 2: #{calculate(wires2, 'a')}"

