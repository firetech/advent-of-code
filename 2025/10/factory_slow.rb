require 'set'
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
      pattern,
      joltage,
      buttons.map { |btn| btn.inject(0) { |r, b| r | (1 << b) } },
      buttons.map { |btn| joltage.each_index.map { |i| btn.include?(i) ? 1 : 0 } },
    ]
  else
    raise "Malformed line: '#{line}'"
  end
end

# For part 2
def part2(joltage, coeff_buttons)
  pattern_costs = {}
  num_buttons = coeff_buttons.length
  num_outputs = coeff_buttons[0].length
  0.upto(num_buttons) do |pattern_length|
    coeff_buttons.combination(pattern_length) do |included_buttons|
      pattern = num_outputs.times.map do |i|
        included_buttons.map { |b| b[i] }.sum
      end
      pattern_costs[pattern] ||= pattern_length
    end
  end

  cache = {}
  bifurcate = ->(target) do
    return 0 if target.all?(0)
    cache_key = target.hash
    result = cache[cache_key]
    if result.nil?
      result = Float::INFINITY
      pattern_costs.each do |pattern, cost|
        next if pattern.zip(target).any? { |p, t| p > t or p % 2 != t % 2 }
        new_target = pattern.zip(target).map { |p, t| (t - p) / 2 }
        this_cost = 2 * bifurcate[new_target] + cost
        result = this_cost if this_cost < result
      end
      cache[cache_key] = result
    end
    return result
  end

  return bifurcate[joltage]
end


@sum_presses1 = 0  # Part 1
@sum_presses2 = 0  # Part 2
stop = nil
begin
  max_runners = [16, @machines.length].min
  input, output, stop, nrunners = Multicore.run(-max_runners) do |worker_in, worker_out|
    sum_presses1 = 0  # Part 1
    sum_presses2 = 0  # Part 2
    worker_in[].each do |pattern, joltage, pattern_buttons, coeff_buttons|
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
        pattern_buttons.each do |btn|
          new_state = state ^ btn
          queue << [new_state, new_presses] if visited.add?(new_state)
        end
      end

      # Part 2
      sum_presses2 += part2(joltage, coeff_buttons)
    end
    worker_out[[sum_presses1, sum_presses2]]
  end
  machines_slice = (@machines.length / nrunners.to_f).ceil
  @machines.each_slice(machines_slice).with_index { |list| input << list }
  (@machines.length / machines_slice.to_f).ceil.times do |i|
    runner_presses1, runner_presses2 = output.pop
    print '.'
    @sum_presses1 += runner_presses1
    @sum_presses2 += runner_presses2
  end
  puts
ensure
  stop[] unless stop.nil?
end

# Part 1
puts "Minimum number of button presses for indicators: #{@sum_presses1}"

# Part 2
puts "Minimum number of button presses for joltage: #{@sum_presses2}"
