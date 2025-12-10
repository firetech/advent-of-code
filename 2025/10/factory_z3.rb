require 'set'
require_relative '../../lib/aoc'
require 'z3'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@machines = []
File.read(file).rstrip.split("\n").each do |line|
  case line
  when /\A\[([\.#]+)\]((?:\s+\([0-9,]+\))+)\s+\{([0-9,]+)\}\z/
    pattern = Regexp.last_match(1).chars.reverse.inject(0) do |p, c|
      p << 1 | (c == '#' ? 1 : 0)
    end
    joltage = Regexp.last_match(3).split(',').map(&:to_i)
    buttons = Regexp.last_match(2).lstrip.split(/\s+/).map do |btn|
      case btn
      when /\A\(([0-9,]+)\)\z/
        Regexp.last_match(1).split(',').map(&:to_i)
      else
        raise "Malformed button: '#{btn}'"
      end
    end
    @machines << [
      [pattern, buttons.map { |btn| btn.inject(0) { |r, b| r | (1 << b) } }],
      [joltage, buttons.map(&:to_set)],
    ]
  else
    raise "Malformed line: '#{line}'"
  end
end

# Part 1
@sum_presses1 = 0
@machines.each do |(pattern, buttons), _|
  visited = Set[0]
  queue = [[0, 0]]
  until queue.empty?
    state, presses = queue.shift

    if state == pattern
      @sum_presses1 += presses
      break
    end

    new_presses = presses + 1
    buttons.each do |btn|
      new_state = state ^ btn
      queue << [new_state, new_presses] if visited.add?(new_state)
    end
  end
end
puts "Minimum number of button presses for indicators: #{@sum_presses1}"

# Part 2
@sum_presses2 = 0
@machines.each do |_, (joltage, buttons)|
  solver = Z3::Optimize.new
  presses = []
  buttons.each_index do |i|
    btn_presses = Z3::Int("button_#{i}")
    solver.assert(btn_presses >= 0)
    presses << btn_presses
  end
  joltage.each_with_index do |value, counter|
    affecting_buttons = buttons.filter_map.with_index { |btn, b| b if btn.include?(counter) }
    solver.assert(affecting_buttons.map { |b| presses[b] }.sum == value)
  end
  solver.minimize(presses.sum)
  raise 'Unsatisfiable?!' unless solver.satisfiable?
  @sum_presses2 += presses.map { |var| solver.model[var].to_i }.sum
end
puts "Minimum number of button presses for joltage: #{@sum_presses2}"
