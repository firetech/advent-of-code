file = 'input'

@program = File.read(file).strip.split("\n").map do |line|
  case line
  when /\Ainp ([w-z])\z/
    [
      :inp,
      Regexp.last_match(1).to_sym
    ]
  when /\A(add|mul|div|mod|eql) ([w-z]) ([w-z])\z/
    [
      Regexp.last_match(1).to_sym,
      Regexp.last_match(2).to_sym,
      Regexp.last_match(3).to_sym
    ]
  when /\A(add|mul|div|mod|eql) ([w-z]) (-?\d+)\z/
    [
      Regexp.last_match(1).to_sym,
      Regexp.last_match(2).to_sym,
      Regexp.last_match(3).to_i
    ]
  else
    raise "Malformed line: '#{line}'"
  end
end

def value(arg, regs)
  if arg.is_a?(Symbol)
    return regs[arg]
  else
    return arg
  end
end

def run(input)
  input_stack = input.digits
  regs = { w: 0, x: 0, y: 0, z: 0 }
  @program.each do |instr, arg1, arg2|
    case instr
    when :inp
      regs[arg1] = input_stack.pop
    when :add
      regs[arg1] += value(arg2, regs)
    when :mul
      regs[arg1] *= value(arg2, regs)
    when :div
      regs[arg1] /= value(arg2, regs)
    when :mod
      regs[arg1] %= value(arg2, regs)
    when :eql
      regs[arg1] = (regs[arg1] == value(arg2, regs) ? 1 : 0)
    else
      raise "Unknown instruction #{instr.inspect}"
    end
  end
  return regs[:z]
end

# See reverse_engineer file for logic.
limits = [
  1..3,  # i14 == i1+6 limits i1 to 1..3
  3..9,  # i13 == i2-2 limits i2 to 3..9
  1..4,  # i12 == i3+5 limits i3 to 1..4
  6..9,  # i5 == i4-5 limits i4 to 6..9
  1..4,  # i5 == i4-5 limits i5 to 1..4
  1..1,  # i11 == i6+8 limits i6 to 1
  5..9,  # i8 == i7-4 limits i7 to 5..9
  1..5,  # i8 == i7-4 limits i8 to 1..5
  1..7,  # i10 == i9+2 limits i9 to 1..7
  3..9,  # i10 == i9+2 limits i9 to 3..9
  9..9,  # i11 == i6+8 limits i11 to 9
  6..9,  # i12 == i3+5 limits i12 to 6..9
  1..7,  # i13 == i2-2 limits i13 to 1..7
  7..9,  # i14 == i1+6 limits i14 to 7..9
]

# Part 1
max_value = limits.map { |l| l.max }.inject(0) { |n, x| n * 10 + x }
raise "Calculated max not valid" unless run(max_value) == 0
puts "Largest valid input: #{max_value}"

# Part 2
min_value = limits.map { |l| l.min }.inject(0) { |n, x| n * 10 + x }
raise "Calculated min not valid" unless run(min_value) == 0
puts "Smallest valid input: #{min_value}"
