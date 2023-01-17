require_relative '../../lib/aoc_api'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

input = File.read(file).strip
case input
when /\Atarget area: x=(\d+)..(\d+), y=(-?\d+)..(-?\d+)\z/
  @target_x = (Regexp.last_match(1).to_i..Regexp.last_match(2).to_i)
  @target_y = (Regexp.last_match(3).to_i..Regexp.last_match(4).to_i)
else
  raise "Malformed line: '#{input}'"
end

# Part 1
# Shooting upwards with y velocity v, you'll get to a point where y=0 (when the
# y velocity is -v). At the next step y will be decreased by -v-1. For y=-v-1 to
# be in the specified y-range, the maximum v must therefore be -@target_y.min-1
# (given that @target_y.min is negative).
vy_max = -@target_y.min - 1
# The highest point during the curve is when the y velocity is 0, which, since
# the y velocity is decreased by 1 each step, is the sum of all integers from v
# down to 1, which is equivalent to v(v+1)/2.
puts "Highest Y value reached: #{vy_max * (vy_max + 1) / 2}"

# Part 2
def simulate(x_vel, y_vel)
  x, y = 0, 0
  last_x = x
  while x <= @target_x.max and y >= @target_y.min
    x += x_vel
    y += y_vel
    return true if @target_x.include?(x) and @target_y.include?(y)
    x_vel -= 1 if x_vel > 0
    # A negative X velocity would never end up in range, no need to handle that.
    return false if x_vel == 0 and x < @target_x.min
    y_vel -= 1
  end
  return false
end

# The lower bound for x velocity is the first sum of integers from 1 to x that
# is >= @target_x.min, i.e. Math.sqrt(@target_x.min*2).round. Any lower than
# that will simply never reach the target before x velocity reaches 0.
vx_min = Math.sqrt(@target_x.min*2).round
# The upper bound is simply @target_x.max. Any higher than that will go past
# the range in the first step.
vx_max = @target_x.max

# The lowest y velocity that will be in range is @target_y.min. Any lower than
# that will go past the range in the first step.
vy_min = @target_y.min
# The upper bound is explained in part 1 above.

count = 0
vy_min.upto(vy_max) do |y_vel|
  vx_min.upto(vx_max) do |x_vel|
    count += 1 if simulate(x_vel, y_vel)
  end
end

puts "Distinct trajectories within range: #{count}"
