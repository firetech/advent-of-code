file = 'input'
#file = 'example1'

# Copied from day 16
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

@program = []
@ip_reg = nil
File.read(file).strip.split("\n").each do |line|
  bad_line = false
  case line
  when /\A#ip ([0-5])\z/
    @ip_reg = Regexp.last_match(1).to_i
  when /\A([a-z]{4})((?: \d+){3})\z/
    op = Regexp.last_match(1).to_sym
    if @opcodes.has_key?(op)
      args = Regexp.last_match(2).split(' ').map(&:to_i)
      @program << [op, *args]
    else
      bad_line = true
    end
  else
    bad_line = true
  end
  raise "Malformed line: '#{line}'" if bad_line
end

# Looping lines 2-15 quite a lot
# ( 1: seti 1 2 1    r1 = 1 )
#   2: seti 1 1 2    r2 = 1
#   3: mulr 1 2 5    r5 = r1 * r2
#   4: eqrr 5 4 5    r5 = (r5 == r4) ? 1 : 0
#   5: addr 5 3 3    goto 7 if r5 == 1
#   6: addi 3 1 3    goto 8
#   7: addr 1 0 0    r0 = r1 + r0
#   8: addi 2 1 2    r2 = r2 + 1
#   9: gtrr 2 4 5    r5 = (r2 > r4) ? 1 : 0
#  10: addr 3 5 3    goto 12 if r5 == 1
#  11: seti 2 3 3    goto 3
#  12: addi 1 1 1    r1 = r1 + 1
#  13: gtrr 1 4 5    r5 = (r1 > r4) ? 1 : 0
#  14: addr 5 3 3    goto 16 if r5 == 1
#  15: seti 1 6 3    goto 2
#
# In other words:
#   r1 = 1
#   do
#     r2 = 1
#     do
#       if r1 * r2 == r4
#         r0 += r1
#       end
#       r2 += 1
#     end until r2 > r4
#     r1 += 1
#   end until r1 > r4
#   r5 = 1
#   ip = r3 = 16
#
#
# ...or, simplified:
#   r0 += (1..r4).select { |x| r4 % x == 0 }.sum
#   r1 = r2 = r4 + 1
#   r5 = 1
#   ip = r3 = 16

OPT_SEQ = [
  [:seti, 1, nil, :outer],
  [:seti, 1, nil, :inner],
  [:mulr, :outer, :inner, :cond],
  [:eqrr, :cond, :num, :cond],
  [:addr, :cond, :ip, :ip],
  [:addi, :ip, 1, :ip],
  [:addr, :outer, :sum, :sum],
  [:addi, :inner, 1, :inner],
  [:gtrr, :inner, :num, :cond],
  [:addr, :ip, :cond, :ip],
  [:seti, :next, nil, :ip],
  [:addi, :outer, 1, :outer],
  [:gtrr, :outer, :num, :cond],
  [:addr, :cond, :ip, :ip],
  [:seti, :this, nil, :ip]
]
OPT_SEQ_INSTR = OPT_SEQ.map(&:first)

def check_opt(regs)
  ip = regs[@ip_reg]
  pgm_seq = @program[ip, OPT_SEQ.length]
  if pgm_seq.map(&:first) == OPT_SEQ_INSTR
    map = {
      1 => 1, # Simplifies the check code...
      this: ip,
      next: ip + 1,
      ip: @ip_reg,
      outer: @program[ip][3],
      inner: @program[ip+1][3],
      cond: @program[ip+2][3],
      num: @program[ip+3][2],
      sum: @program[ip+6][3]
    }
    match = pgm_seq.zip(OPT_SEQ).all? do |line, check_line|
      line[1..-1].zip(check_line[1..-1]).all? { |l, c| c.nil? or l == map[c] }
    end
    if match
      n = regs[map[:num]]
      regs[map[:sum]] += (1..n).select { |x| n % x == 0 }.sum
      regs[map[:outer]] = regs[map[:inner]] = regs[map[:num]] + 1
      regs[map[:cond]] = 1
      regs[map[:ip]] += OPT_SEQ.length - 1
    end
    return match
  end
  return false
end

2.times do |i|
  regs = Array.new(6, 0)
  regs[0] = i
  pgm_length = @program.length
  while (0...pgm_length).include?(regs[@ip_reg])
    unless check_opt(regs)
      instr = @program[regs[@ip_reg]]
      run(*instr, regs)
    end
    regs[@ip_reg] += 1
  end
  puts "Register 0 value (when initialized to #{i}): #{regs[0]}"
end
