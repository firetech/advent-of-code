input = File.read('input').strip

require_relative '../lib/intcode'
require 'set'

@droid = Intcode.new(input, false)
@grid = { [0,0] => 1 }
@goal_x = nil
@goal_y = nil
@min_x = 0
@max_x = 0
@min_y = 0
@max_y = 0

def dir_to_xy(dir, x, y)
  case dir
  when 1
    y -= 1
  when 2
    y += 1
  when 3
    x -= 1
  when 4
    x += 1
  end
  return x, y
end

@reverse_of = { 1 => 2, 2 => 1, 3 => 4, 4 => 3 }
def walk(from_x, from_y)
  (1..4).each do |dir|
    x, y = dir_to_xy(dir, from_x, from_y)
    if not @grid.has_key?([x, y])
      @min_x = [@min_x, x].min
      @min_y = [@min_y, y].min
      @max_x = [@max_x, x].max
      @max_y = [@max_y, y].max

      @droid << dir
      output = @droid.output
      @grid[[x,y]] = output

      if output == 2
        if not @goal_x.nil? or not @goal_y.nil?
          raise 'Multiple goals?'
        end
        @goal_x = x
        @goal_y = y
      end
      if output != 0
        walk(x, y)
        @droid << @reverse_of[dir]
        @droid.pop # Skip known output
      end
    end
  end
end

begin
  @thread = Thread.new { @droid.run }
  walk(0, 0)
ensure
  @thread.kill
end

# Entirely optional, print map
#=begin
(@min_y..@max_y).each do |y|
  (@min_x..@max_x).each do |x|
    if x == 0 and y == 0
      print '*'
    else
      print case @grid[[x,y]]
            when nil
              "\u2591"
            when 1
              ' '
            when 0
              "\u2588"
            when 2
              'O'
            end
    end
  end
  puts
end
#=end

queue = [ [@goal_x, @goal_y, 0] ]
visited = Set.new
steps_to_start = nil
minutes_to_fill = nil
while not queue.empty?
  from_x, from_y, from_steps = queue.shift
  visited << [from_x, from_y]
  (1..4).each do |dir|
    x, y = dir_to_xy(dir, from_x, from_y)
    if @grid[[x,y]] == 1 and not visited.include?([x,y])
      queue << [x, y, from_steps + 1]
    end
  end
  # part 1
  if from_x == 0 and from_y == 0
    steps_to_start = from_steps
  end
  # part 2
  if queue.empty?
    minutes_to_fill = from_steps
  end
end
puts "Minimum steps to oxygen system: #{steps_to_start}"
puts "Minutes until filled: #{minutes_to_fill}"
