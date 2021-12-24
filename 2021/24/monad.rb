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

def check_line(input_line, expected_line)
  match = false
  if input_line.length == expected_line.length
    match = input_line.zip(expected_line).all? do |inp, exp|
      exp.nil? or inp == exp
    end
  end
  unless match
    expected_str = expected_line.map { |x| x.nil? ? '*' : x }.join(' ')
    raise "Expected '#{expected_str}', got '#{input_line.join(' ')}'"
  end
end

stack = []
@checks = {}
@program.each_slice(@program.length/14).with_index do |p, i|
  # Every digit follows this path
  # See reverse_engineer file for logic
  check_line(p[0],  [:inp, :w])
  check_line(p[1],  [:mul, :x, 0])
  check_line(p[2],  [:add, :x, :z])
  check_line(p[3],  [:mod, :x, 26])
  check_line(p[4],  [:div, :z, nil])
  check_line(p[5],  [:add, :x, nil])
  check_line(p[6],  [:eql, :x, :w])
  check_line(p[7],  [:eql, :x, 0])
  check_line(p[8],  [:mul, :y, 0])
  check_line(p[9],  [:add, :y, 25])
  check_line(p[10], [:mul, :y, :x])
  check_line(p[11], [:add, :y, 1])
  check_line(p[12], [:mul, :z, :y])
  check_line(p[13], [:mul, :y, 0])
  check_line(p[14], [:add, :y, :w])
  check_line(p[15], [:add, :y, nil])
  check_line(p[16], [:mul, :y, :x])
  check_line(p[17], [:add, :z, :y])
  # Check type of digit handling
  case p[4][2]
  when 1
    # Just adding value to the "stack" (the p[6] check will never be true)
    stack_top_offset = stack.empty? ? 0 : stack.last.last
    raise "Dummy check could be true" if (stack_top_offset + p[5][2]).abs < 9
    stack << [i, p[15][2]]
  when 26
    # Checking digit against "stack" top
    index, offset = stack.pop
    offset += p[5][2]
    @checks[i] = [index, offset]
  else
    raise "Unexpected z division by #{p[4][2]}"
  end
end
raise "Stack not empty" unless stack.empty?

@limits = Array.new(14)
@checks.each do |i1, (i2, offset)|
  if offset < 0
    i2, i1 = i1, i2
    offset = - offset
  end
  @limits[i1] = (1 + offset)..9
  @limits[i2] = 1..(9 - offset)
end

# Part 1
max_value = @limits.map { |l| l.max }.inject(0) { |n, x| n * 10 + x }
raise "Calculated max not valid" unless run(max_value) == 0
puts "Largest valid input: #{max_value}"

# Part 2
min_value = @limits.map { |l| l.min }.inject(0) { |n, x| n * 10 + x }
raise "Calculated min not valid" unless run(min_value) == 0
puts "Smallest valid input: #{min_value}"
