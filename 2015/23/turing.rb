require_relative '../../lib/aoc_api'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

input = File.read(file).strip.split("\n").map do |line|
  case line
  when /\A(hlf|tpl|inc) (a|b)\z/
    [ Regexp.last_match(1).to_sym, Regexp.last_match(2) ]
  when /\Ajmp ([+-]\d+)\z/
    [ :jmp, Regexp.last_match(1).to_i ]
  when /\A(jie|jio) (a|b), ([+-]\d+)\z/
    [ Regexp.last_match(1).to_sym, Regexp.last_match(2), Regexp.last_match(3).to_i ]
  else
    raise "Malformed line: '#{line}'"
  end
end

def run(code, reg = { 'a' => 0, 'b' => 0 })
  ip = 0
  while ip >= 0 and ip < code.length
    next_ip = ip + 1
    instr, arg1, arg2 = code[ip]
    case instr
    when :hlf
      reg[arg1] /= 2
    when :tpl
      reg[arg1] *= 3
    when :inc
      reg[arg1] += 1
    when :jmp
      next_ip = ip + arg1
    when :jie
      if reg[arg1] % 2 == 0
        next_ip = ip + arg2
      end
    when :jio
      if reg[arg1] == 1
        next_ip = ip + arg2
      end
    end
    ip = next_ip
  end
  return reg
end

puts "Value of b after execution: #{run(input)['b']}"
puts "Value of b after execution with a=1: #{run(input, { 'a' => 1, 'b' => 0 })['b']}"

