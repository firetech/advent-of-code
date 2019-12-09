require 'pp'
input = File.read('input').strip.split("\n")

#part 1
#lights = Array.new(1000000, false)
#part 2
lights = Array.new(1000000, 0)
def i(x, y)
  return x * 1000 + y
end

input.each do |line|
  if line =~ /\A(turn on|toggle|turn off) (\d+),(\d+) through (\d+),(\d+)\z/
    action = Regexp.last_match[1]
    x_min = Regexp.last_match[2].to_i
    y_min = Regexp.last_match[3].to_i
    x_max = Regexp.last_match[4].to_i
    y_max = Regexp.last_match[5].to_i
    (x_min..x_max).each do |x|
      (y_min..y_max).each do |y|
        #part 1
=begin
        lights[i(x,y)] = case action
          when 'turn on'
            true
          when 'toggle'
            (not lights[i(x,y)])
          when 'turn off'
            false
        end
=end
        #part 2
#=begin
        lights[i(x,y)] = case action
          when 'turn on'
            lights[i(x,y)] + 1
          when 'toggle'
            lights[i(x,y)] + 2
          when 'turn off'
            [lights[i(x,y)] - 1, 0].max
#=end
        end
      end
    end
  else
    raise "Malformed line: #{line}"
  end
end

#part 1
#puts "#{lights.count(true)} lights are on"
#part 2
puts "Total brightness: #{lights.inject(0) { |sum, x| sum + x }}"
