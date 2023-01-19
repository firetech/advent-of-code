require 'set'
require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@opcodes = {
  addr: ->(a, b, c, r) { r[c] = r[a] + r[b] },
  addi: ->(a, b, c, r) { r[c] = r[a] + b },
  mulr: ->(a, b, c, r) { r[c] = r[a] * r[b] },
  muli: ->(a, b, c, r) { r[c] = r[a] * b },
  banr: ->(a, b, c, r) { r[c] = r[a] & r[b] },
  bani: ->(a, b, c, r) { r[c] = r[a] & b },
  borr: ->(a, b, c, r) { r[c] = r[a] | r[b] },
  bori: ->(a, b, c, r) { r[c] = r[a] | b },
  setr: ->(a, b, c, r) { r[c] = r[a] },
  seti: ->(a, b, c, r) { r[c] = a },
  gtir: ->(a, b, c, r) { r[c] = (a > r[b]) ? 1 : 0 },
  gtri: ->(a, b, c, r) { r[c] = (r[a] > b) ? 1 : 0 },
  gtrr: ->(a, b, c, r) { r[c] = (r[a] > r[b]) ? 1 : 0 },
  eqir: ->(a, b, c, r) { r[c] = (a == r[b]) ? 1 : 0 },
  eqri: ->(a, b, c, r) { r[c] = (r[a] == b) ? 1 : 0 },
  eqrr: ->(a, b, c, r) { r[c] = (r[a] == r[b]) ? 1 : 0 },
}

def run(opcode, a, b, c, regs)
  @opcodes[opcode][a, b, c, regs]
end

samples_str, program_str = File.read(file).strip.split("\n\n\n\n")

# Part 1 (including preparations for Part 2)
found_opcodes = Set[]
@samples = samples_str.strip.split("\n\n").map do |sample|
  before_str, code_str, after_str = sample.split("\n")
  if before_str =~ /\ABefore: +\[(\d+, \d+, \d+, \d+)\]\z/
    before = Regexp.last_match(1).split(', ').map(&:to_i)
  else
    raise "Malformed line: '#{before_str}'"
  end
  code = code_str.split(' ').map(&:to_i)
  found_opcodes << code.first
  if after_str =~ /\AAfter: +\[(\d+, \d+, \d+, \d+)\]\z/
    after = Regexp.last_match(1).split(', ').map(&:to_i)
  else
    raise "Malformed line: '#{after_str}'"
  end
  [code, before, after]
end

matching_three_or_more = 0
@matching = @opcodes.transform_values { found_opcodes.clone }
@samples.each do |code, before, after|
  matching_opcodes = 0
  @opcodes.keys.each do |opcode|
    regs = before.clone
    run(opcode, code[1], code[2], code[3], regs)
    if regs == after
      matching_opcodes += 1
    else
      @matching[opcode].delete(code[0])
      if @matching[opcode].empty?
        raise "No possible values left for #{opcode}"
      end
    end
  end
  matching_three_or_more += 1 if matching_opcodes >= 3
end

puts "Samples matching three or more opcodes: #{matching_three_or_more}"

# Part 2
@program = program_str.split("\n").map { |line| line.split(' ').map(&:to_i) }

@value_to_op = {}
while @value_to_op.length < @opcodes.length
  singles = @matching.select { |_, values| values.length == 1 }
  raise "No opcode eligible for process of elimination" if singles.empty?
  singles.each do |opcode, values|
    op_value = values.first
    @value_to_op[op_value] = opcode
    @matching.delete(opcode)
    @matching.each_value { |values| values.delete(op_value) }
  end
end

regs = Array.new(4, 0)
@program.each do |op_value, a, b, c|
  run(@value_to_op[op_value], a, b, c, regs)
end
puts "Register 0 content after running test program: #{regs[0]}"
