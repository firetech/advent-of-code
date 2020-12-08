require 'set'

input = File.read('input').strip.split("\n")
#input = File.read('example1').strip.split("\n")

code = input.map do |line|
  if line =~ /\A(\w+) ([+-]\d+)\z/
    instr = Regexp.last_match(1).to_sym
    val = Regexp.last_match(2).to_i
    [ instr, val ]
  else
    raise "Malformed instruction '#{line}'"
  end
end

def run(lines)
  visited = Set.new
  i = 0
  acc = 0
  until visited.include?(i) or i >= lines.length
    visited << i
    instr, val = lines[i]
    i += 1
    case instr
    when :nop
      # Do nothing
    when :acc
      acc += val
    when :jmp
      i += val - 1 # offset for auto-increment above
    else
      raise "Unknown instruction: '#{instr}'"
    end
  end
  return acc, i == lines.length
end

#part 1
acc, complete = run(code)
puts "Value of accumulator before first loop: #{acc}"

#part 2
indices = code.each_index.select { |i| [:nop, :jmp].include?(code[i].first) }
indices.each do |i|
  orig = code[i]
  code[i] = [
    code[i].first == :nop ? :jmp : :nop,
    code[i].last
  ]
  acc, complete = run(code)
  code[i] = orig
  if complete
    puts "Changing line #{i} to #{code[i][0]} fixed code, resulting accumulator: #{acc}"
    break
  end
end
