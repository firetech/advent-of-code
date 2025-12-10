require 'set'
require 'z3'
require_relative '../../lib/aoc'
require_relative '../../lib/multicore'

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


@sum_presses1 = 0  # Part 1
@sum_presses2 = 0  # Part 2
stop = nil
begin
  max_runners = [16, @machines.length].min
  input, output, stop, nrunners = Multicore.run(-max_runners) do |worker_in, worker_out|
    sum_presses1 = 0  # Part 1
    sum_presses2 = 0  # Part 2
    worker_in[].each do |(pattern, buttons1), (joltage, buttons2)|
      # Part 1
      visited = Set[0]
      queue = [[0, 0]]
      until queue.empty?
        state, presses = queue.shift

        if state == pattern
          sum_presses1 += presses
          break
        end

        new_presses = presses + 1
        buttons1.each do |btn|
          new_state = state ^ btn
          queue << [new_state, new_presses] if visited.add?(new_state)
        end
      end

      # Part 2
      solver = Z3::Optimize.new
      presses = buttons2.each_index.map do |i|
        btn_presses = Z3::Int("button_#{i}")
        solver.assert(btn_presses >= 0)
        btn_presses
      end
      joltage.each_with_index do |value, counter|
        affecting_buttons = buttons2.filter_map.with_index { |btn, b| b if btn.include?(counter) }
        solver.assert(affecting_buttons.map { |b| presses[b] }.sum == value)
      end
      solver.minimize(presses.sum)
      raise 'Unsatisfiable?!' unless solver.satisfiable?
      sum_presses2 += presses.map { |var| solver.model[var].to_i }.sum
    end
    worker_out[[sum_presses1, sum_presses2]]
  end
  machines_slice = (@machines.length / nrunners.to_f).ceil
  @machines.each_slice(machines_slice).with_index { |list| input << list }
  (@machines.length / machines_slice.to_f).ceil.times do |i|
    runner_presses1, runner_presses2 = output.pop
    @sum_presses1 += runner_presses1
    @sum_presses2 += runner_presses2
  end
ensure
  stop[] unless stop.nil?
end

# Part 1
puts "Minimum number of button presses for indicators: #{@sum_presses1}"

# Part 2
puts "Minimum number of button presses for joltage: #{@sum_presses2}"
