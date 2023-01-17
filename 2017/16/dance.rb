require_relative '../../lib/aoc_api'

file = ARGV[0] || AOC.input_file()
last_program = ARGV[1] || 'p'
part2_rounds = (ARGV[2] || 1_000_000_000).to_i

#file = 'example1'; last_program = 'e'; part2_rounds = 2

programs = ('a'..last_program).to_a
index_moves = (0...programs.length).to_a
substitutions = programs.map { |p| [p, p] }.to_h

File.read(file).strip.split(',').each do |move|
  case move
  when /\As(\d+)\z/
    x = Regexp.last_match(1).to_i
    index_moves.rotate!(-x)
  when /\Ax(\d+)\/(\d+)\z/
    a = Regexp.last_match(1).to_i
    b = Regexp.last_match(2).to_i
    index_moves[a], index_moves[b] = index_moves[b], index_moves[a]
  when /\Ap(\w)\/(\w)\z/
    a = Regexp.last_match(1)
    b = Regexp.last_match(2)
    substitutions.transform_values! do |v|
      if v == a
        b
      elsif v == b
        a
      else
        v
      end
    end
  end
end

# Part 1
part1_state = index_moves.map { |i| substitutions[programs[i]] }.join
puts "State after 1 cycle: #{part1_state}"

# Part 2
rounds = part2_rounds
part2_programs = programs.clone
part2_moves = index_moves.clone
part2_subst = substitutions.clone
# https://en.wikipedia.org/wiki/Exponentiation_by_squaring
while rounds > 0
  if (rounds & 1) > 0
    part2_programs = part2_moves.map { |i| part2_subst[part2_programs[i]] }
  end

  part2_moves = part2_moves.map { |i| part2_moves[i] }
  part2_subst = part2_subst.transform_values { |v| part2_subst[v] }

  rounds >>= 1
end
puts "State after #{part2_rounds} cycles: #{part2_programs.join}"
