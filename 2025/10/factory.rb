require 'set'
require_relative '../../lib/aoc'

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
@sum_presses1 = 0
@machines.each do |pattern, buttons, _|
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
