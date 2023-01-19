require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'
#file = 'example2'

# Input parsing
ARG_REG = /[a-z]/
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
  when /\A(snd|rcv) (#{ARG})\z/
    @program << [
      Regexp.last_match(1).to_sym,
      parse_arg(Regexp.last_match(2))
    ]
  when /\A(set|add|mul|mod|jgz) (#{ARG}) (#{ARG})\z/
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

def run(regs, snd_proc, rcv_proc)
  pc = 0
  while (0...@program.length).include?(pc)
    instr, *arg = @program[pc]
    next_pc = pc + 1
    case instr
    when :snd
      snd_proc.call(arg[0])
    when :set
      set(regs, arg[0], get(regs, arg[1]))
    when :add
      set(regs, arg[0], get(regs, arg[0]) + get(regs, arg[1]))
    when :mul
      set(regs, arg[0], get(regs, arg[0]) * get(regs, arg[1]))
    when :mod
      set(regs, arg[0], get(regs, arg[0]) % get(regs, arg[1]))
    when :rcv
      if rcv_proc.call(arg[0])
        break
      end
    when :jgz
      if get(regs, arg[0]) > 0
        next_pc = pc + get(regs, arg[1])
      end
    end
    pc = next_pc
  end
end

# Part 1
regs = Hash.new(0)
last_sound = nil
run(
  regs,
  ->(arg) {
    last_sound = get(regs, arg)
  },
  ->(arg) {
    if get(regs, arg) != 0
      puts "Recover frequency: #{last_sound}"
      return true
    end
    return false
  }
)

# Part 2
regs = []
queues = []
waiting = []
sends = []
threads = []
mutex = Mutex.new
0.upto(1) do |p|
  regs[p] = Hash.new(0)
  regs[p]['p'] = p
  queues[p] = Queue.new
  waiting[p] = false
  sends[p] = 0

  threads[p] = Thread.new do
    begin
      start = queues[p].pop
      if start != :start
        raise "Expected :start, got #{start}"
      end
      run(
        regs[p],
        ->(arg) {
          sends[p] += 1
          mutex.synchronize do
            queues[1-p] << get(regs[p], arg)
          end
        },
        ->(arg) {
          waiting[p] = true
          mutex.synchronize do
            if waiting[1-p] and queues[1-p].empty? and queues[p].empty?
              queues.each(&:close)
              return true
            end
          end
          val = queues[p].pop
          if val.nil?
            return true
          end
          waiting[p] = false
          set(regs[p], arg, val)
          return false
        }
      )
    ensure
      queues[p].close
    end
  end
end
queues.each { |q| q << :start }
threads.each(&:join)
puts "Program 1 snd counter: #{sends[1]}"
