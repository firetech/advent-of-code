require_relative '../../lib/aoc_api'

file = ARGV[0] || AOC.input_file()

# Input parsing
ARG_REG = /[a-h]/
ARG_IMM = /-?\d+/
ARG = /(?:#{ARG_REG}|#{ARG_IMM})/
def parse_arg(match)
  case match
  when /\A#{ARG_REG}\z/
    return [:reg, match]
  when /\A#{ARG_IMM}\z/
    return [:imm, match.to_i]
  else
    raise "Malformed argument: '#{match}'"
  end
end

@program = []
File.read(file).strip.split("\n").each do |line|
  case line
  when /\A(set|sub|mul|jnz) (#{ARG}) (#{ARG})\z/
    @program << [
      Regexp.last_match(1).to_sym,
      parse_arg(Regexp.last_match(2)),
      parse_arg(Regexp.last_match(3))
    ]
  end
end

# Program running
def get(regs, arg)
  type, content = arg
  case type
  when :reg
    return regs[content]
  when :imm
    return content
  else
    raise "Invalid argument type: #{type}"
  end
end

def set(regs, arg, val)
  type, content = arg
  case type
  when :reg
    regs[content] = val
  when :imm
    raise "Cannot change immediate value #{content}"
  else
    raise "Invalid argument: #{arg}"
  end
end

def run()
  regs = Hash.new(0)
  pc = 0
  mul_count = 0
  while (0...@program.length).include?(pc)
    instr, *arg = @program[pc]
    next_pc = pc + 1
    case instr
    when :set
      set(regs, arg[0], get(regs, arg[1]))
    when :sub
      set(regs, arg[0], get(regs, arg[0]) - get(regs, arg[1]))
    when :mul
      set(regs, arg[0], get(regs, arg[0]) * get(regs, arg[1]))
      mul_count += 1
    when :jnz
      if get(regs, arg[0]) != 0
        next_pc = pc + get(regs, arg[1])
      end
    end
    pc = next_pc
  end
  return mul_count
end

puts "mul executed #{run} times"
