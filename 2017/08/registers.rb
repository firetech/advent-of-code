require_relative '../../lib/aoc_api'

input = File.read(ARGV[0] || AOC.input_file()).strip
#input = File.read('example1').strip

OPS = {
  'inc' => :+,
  'dec' => :-
}

regs = Hash.new(0)
seen_max = nil

input.split("\n").each do |line|
  if line =~ /\A(\w+) (inc|dec) (-?\d+) if (\w+) (<|>|<=|>=|==|!=) (-?\d+)\z/
    _, reg, op, val, cond_reg, cond_op, cond_val = Regexp.last_match.to_a
    if regs[cond_reg].send(cond_op.to_sym, cond_val.to_i)
      regs[reg] = regs[reg].send(OPS[op], val.to_i)
      if seen_max.nil? or seen_max < regs[reg]
        seen_max = regs[reg]
      end
    end
  else
    raise "Malformed line: '#{line}'"
  end
end

# Part 1
puts "Max at end of program: #{regs.values.max}"

# Part 2
puts "Seen maximum: #{seen_max}"
