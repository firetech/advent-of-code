file = 'input'
#file = 'example1'

input = File.read(file).strip
case input
when /\Atarget area: x=(-?\d+)..(-?\d+), y=(-?\d+)..(-?\d+)\z/
  @target_x = (Regexp.last_match(1).to_i..Regexp.last_match(2).to_i)
  @target_y = (Regexp.last_match(3).to_i..Regexp.last_match(4).to_i)
else
  raise "Malformed line: '#{input}'"
end

def simulate(x_vel, y_vel)
  x, y = 0, 0
  last_x = x
  highest_y = 0
  while x_vel != 0 and x <= @target_x.max
    x += x_vel
    y += y_vel
    highest_y = y if y > highest_y
    x_vel -= 1 if x_vel > 0
    # A negative X velocity would never end up in range, no need to handle that.
    y_vel -= 1
    return true, highest_y if @target_x.include?(x) and @target_y.include?(y)
  end
  return false unless @target_x.include?(x)
  while y > @target_y.max
    y += y_vel
    highest_y = y if y > highest_y
    y_vel -= 1
  end
  return @target_y.include?(y), highest_y
end

highest_y = -Float::INFINITY  # Part 1
count = 0  # Part 2
@target_y.min.upto(@target_x.max * 2) do |y_vel|
  0.upto(@target_x.max * 2) do |x_vel|
    hit, high_y = simulate(x_vel, y_vel)
    if hit
      count += 1
      highest_y = high_y if high_y > highest_y
    end
  end
end

# Part 1
puts "Highest Y value reached: #{highest_y}"

# Part 2
puts "Distinct trajectories within range: #{count}"
