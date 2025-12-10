require_relative '../../lib/aoc'
require_relative '../../lib/priority_queue'

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
        Regexp.last_match(1).split(',').map(&:to_i).inject(0) do |r, b|
          r | (1 << b)
        end
      else
        raise "Malformed button: '#{btn}'"
      end
    end
    @machines << [pattern, buttons, joltage]
  else
    raise "Malformed line: '#{line}'"
  end
end

# Part 1
@sum_presses = 0
@machines.each do |pattern, buttons, _|
  cost = Hash.new(Float::INFINITY)
  queue = PriorityQueue.new
  cost[0] = 0
  queue.push(0, 0)
  until queue.empty?
    state = queue.pop_min
    this_cost = cost[state]

    if state == pattern
      @sum_presses += this_cost
      break
    end

    buttons.each do |btn|
      new_state = state ^ btn
      new_cost = this_cost + 1
      if new_cost < cost[new_state]
        cost[new_state] = new_cost
        queue.push(new_state, new_cost)
      end
    end
  end
end
puts "Minimum number of button presses for indicators: #{@sum_presses}"
