require 'set'
require_relative '../../lib/aoc'
require_relative '../../lib/priority_queue'
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
      pattern, buttons.map { |btn| btn.inject(0) { |r, b| r | (1 << b) } },
      joltage, buttons.map(&:to_set),
    ]
  else
    raise "Malformed line: '#{line}'"
  end
end


# For part 2
class ButtonPresser
  def initialize(joltage, buttons)
    @joltage = joltage
    @num_joltage = joltage.length

    # Sort buttons.
    # * Most unique counter first.
    # * When multiple buttons affect the same counter, sort by decreasing amount
    #   of affected counters.
    @buttons = []
    @num_buttons = buttons.length
    buttons_left = buttons.to_set
    until buttons_left.empty?
      counts = Hash.new(0)
      buttons_left.each do |affecting|
        affecting.each { |i| counts[i] += 1 }
      end
      min_affected = counts.key(counts.values.min)
      next_btn = nil
      buttons_left.each do |btn|
        next unless btn.include?(min_affected)
        next_btn = btn if next_btn.nil? or btn.count > next_btn.count
      end
      buttons_left.delete(next_btn)
      @buttons << next_btn
    end

    # Calculate number of buttons available for each counter after considering
    # each button (in the order above) done.
    @buttons_remaining_per_counter = @buttons.map { @joltage.map { 0 } }
    @buttons.each_index.reverse_each do |b|
      @joltage.each_index do |id|
        @buttons_remaining_per_counter[b][id] += (
          @buttons_remaining_per_counter[b + 1][id] rescue 0
        )
      end
      @buttons[b].each do |id|
        @buttons_remaining_per_counter[b][id] += 1
      end
    end

    @best = Float::INFINITY
  end

  def traverse(remaining = @joltage, button_index = 0, presses = 0)
    return if presses >= @best or presses + remaining.max >= @best  # Can't beat

    if button_index == @num_buttons
      @best = presses if remaining.all?(0)
      return
    end

    # Find boundaries for this button given the circumstances.
    min = 0
    max = Float::INFINITY
    button = @buttons[button_index]
    button.each do |id|
      r = remaining[id]
      max = r if r < max
      if @buttons_remaining_per_counter[button_index][id] == 1
        min = r if r > min
      end
    end

    return if min > max

    # Try all the possibilites and go on to the next button.
    max.downto(min) do |new_presses|
      new_remaining = remaining.map.with_index do |curr, id|
        this_presses = (button.include?(id) ? new_presses : 0)
        break if this_presses > curr
        curr - this_presses
      end
      next if new_remaining.nil?
      traverse(new_remaining, button_index + 1, presses + new_presses)
    end
  end

  def solve
    traverse
    return @best
  end
end

@sum_presses1 = 0  # Part 1
@sum_presses2 = 0  # Part 2
stop = nil
begin
  input, output, stop, nrunners = Multicore.run(-@machines.length) do |worker_in, worker_out|
    sum_presses1 = 0  # Part 1
    sum_presses2 = 0  # Part 2
    loop do
      machine = worker_in[]
      break if machine == :done

      pattern, buttons1, joltage, buttons2 = machine
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
      sum_presses2 += ButtonPresser.new(joltage, buttons2).solve()
    end
    worker_out[[sum_presses1, sum_presses2]]
  end
  @machines.each { |m| input << m }
  nrunners.times do
    input << :done
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
