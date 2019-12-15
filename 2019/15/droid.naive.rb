input = File.read('input').strip

require_relative '../lib/intcode'
require 'set'

@droid = Intcode.new(input, false)
@grid = { [0,0] => 1 }
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

@left_of = { 1 => 3, 2 => 4, 3 => 2, 4 => 1 }
@right_of = { 1 => 4, 2 => 3, 3 => 1, 4 => 2 }
@reverse_of = { 1 => 2, 2 => 1, 3 => 4, 4 => 3 }

def walk(dir_transforms)
  begin
    @droid.reset
    at_x = 0
    at_y = 0
    thread = Thread.new { @droid.run }
    dir = 4
    output = 1
    while output != 2
      dir_transforms.each do |transform|
        if not transform.nil?
          cmd = transform[dir]
        else
          cmd = dir
        end
        @droid << cmd
        output = @droid.output

        x, y = dir_to_xy(cmd, at_x, at_y)
        @min_x = [@min_x, x].min
        @min_y = [@min_y, y].min
        @max_x = [@max_x, x].max
        @max_y = [@max_y, y].max
        @grid[[x,y]] = output

        if output != 0
          dir = cmd
          at_x = x
          at_y = y
          break
        end
      end
    end
    return at_x, at_y
  ensure
    thread.kill
  end
end

# Follow left wall
goal_x, goal_y = walk([@left_of, nil, @right_of, @reverse_of])

# Follow right wall
goal_x, goal_y = walk([@right_of, nil, @left_of, @reverse_of])

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

queue = [ [goal_x, goal_y, 0] ]
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
