require_relative '../../lib/aoc_api'
require_relative '../lib/intcode'

input = File.read(ARGV[0] || AOC.input_file()).strip

@drone = Intcode.new(input, false)

def check(x, y)
  @drone.reset
  @drone << x
  @drone << y
  @drone.run
  return (@drone.output == 1)
end

# part 1
count = 0
last_start = 0
last_end = 0
(0..49).each do |y|
  beam_found = false
  (last_start..49).each do |x|
    if check(x, y)
      count += 1
      if not beam_found
        last_start = x
        beam_found = true
      end
    elsif beam_found
      last_end = x - 1
      break
    end
  end
end
puts "#{count} points in 50x50 area"

# part 2
x = last_start
# Make an estimate on which y pos the beam is at least 100 positions wide
y = (50.0 / (last_end - last_start)).to_i * 100
# Since we're checking the lower left corner in the loop, jump down 99 positions
y += 99
ans = nil
while ans.nil?
  y += 1
  while not check(x, y)
    x += 1
  end

  if check(x + 99, y - 99)
    ans = [x, y - 99]
  end
end
puts "Position: (#{ans.join(',')}) (answer: #{ans[0] * 10000 + ans[1]})"

