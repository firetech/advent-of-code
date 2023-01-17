require_relative '../../lib/aoc_api'

input = File.read(ARGV[0] || AOC.input_file()).strip
#input = File.read('example1').strip

program = input.split("\n").map(&:to_i)

def run_program!(program)
  pc = 0
  steps = 0

  while (0...program.length).include?(pc)
    new_pc = pc + program[pc]
    program[pc] = yield program[pc]
    pc = new_pc
    steps +=1
  end

  return steps
end

# Part 1
part1_steps = run_program!(program.clone) { |val| val + 1 }
puts "Steps in always increasing mode: #{part1_steps}"

# Part 2
part2_steps = run_program!(program.clone) do |val|
  if val >= 3
    val - 1
  else
    val + 1
  end
end
puts "Steps in converging mode: #{part2_steps}"
