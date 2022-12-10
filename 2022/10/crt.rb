file = ARGV[0] || 'input'
#file = 'example1'
#file = 'example2'

@code = File.read(file).rstrip.split("\n").map do |line|
  case line
  when /\Anoop\z/
    [:noop]
  when /\Aaddx (-?\d+)\z/
    [:addx, Regexp.last_match(1).to_i]
  else
    raise "Malformed line: '#{line}'"
  end
end

# Part 1 variables
CHECK = [20, 60, 100, 140, 180, 220]
cycle = 1
strength_sum = 0

# Part 2 variables
screen = Array.new(6) { [' '] * 40 }
screen_x = 0
screen_y = 0

i = 0
x = 1
next_cycle_add = nil
while screen_y < screen.length
  # Part 1
  if CHECK.include?(cycle)
    strength_sum += cycle * x
  end

  # Part 2
  if (x - screen_x).abs <= 1
    screen[screen_y][screen_x] = "\u2588"
  end

  if next_cycle_add.nil?
    instr, value = @code[i]
    i += 1
    case instr
    when :addx
      raise unless next_cycle_add.nil?
      next_cycle_add = value
    when :noop
      # Do nothing
    else
      raise "Unknown instruction #{instr.inspect} at cycle #{cycle}"
    end
  else
    x += next_cycle_add
    next_cycle_add = nil
  end

  cycle += 1
  screen_x += 1
  if screen_x >= screen.first.length
    screen_x = 0
    screen_y += 1
  end
end

# Part 1
puts "Sum of interesting signal strengths: #{strength_sum}"

# Part 2
screen.each { |line| puts line.join }
