require 'set'
require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1' # (given in part 2)

nodes = {}
max_x = 0
max_y = 0
empty = []
File.read(file).strip.split("\n").map do |line|
  case line
  when /df -h\z/, /\AFilesystem/
    next
  when /\A\/dev\/grid\/node-x(\d+)-y(\d+)\s+(\d+)T\s+(\d+)T\s+(\d+)T\s+\d+%\z/
    x = Regexp.last_match(1).to_i
    if x > max_x
      max_x = x
    end
    y = Regexp.last_match(2).to_i
    if y > max_y
      max_y = y
    end
    key = [x, y]
    size = Regexp.last_match(3).to_i
    used = Regexp.last_match(4).to_i
    avail = Regexp.last_match(5).to_i
    nodes[key] = [size, used, avail]
    if used == 0
      empty << key
    end
  end
end

##########
# Part 1 #
##########
viable = Set.new
nodes.to_a.combination(2) do |(a, (_, a_used, a_avail)), (b, (_, b_used, b_avail))|
  # Turns out, all viable pairs include the single empty space, let's use this for part 2
  if a_used > 0 and b_avail >= a_used
    viable << a
    if b_used > 0
      STDERR.puts "Warning: Viable pair did't include the empty space. Step calculation will likely be wrong."
    end
  end
  if b_used > 0 and a_avail >= b_used
    viable << b
    if a_used > 0
      STDERR.puts "Warning: Viable pair did't include the empty space. Step calculation will likely be wrong."
    end
  end
end
puts "#{viable.count} viable pairs"

##########
# Part 2 #
##########
if empty.size != 1
  raise "#{empty.size} empty nodes found, expected 1"
end

# Here, we assume the data looks something like:
# !....G      !....G
# ......  or  ......
# ..####      ####..
# ...._.      .._...
#
# i.e. free path between goal node (G) and 0,0 (!) and on the entire second row.
# This means that all nodes with y = 0 and y = 1 must be part of a viable pair
# (with the empty node (_) being the other part).
(0..1).each do |y|
  (0..max_x).each do |x|
    pos = [x, y]
    if not viable.include?(pos) and empty.first != pos
      raise "This solution won't work, node-x#{x}-y#{y} is not viable. :("
    end
  end
end

# Find steps to move empty space to left neighbour or goal node
queue = [ [*empty.first, 0] ]
visited = Set.new
steps_to_left_of_goal = nil
while steps_to_left_of_goal.nil? and not queue.empty?
  x, y, steps = queue.shift
  # No reason to move down, except to explode the space...
  [[0, -1], [1, 0], [-1, 0]].each do |dx, dy|
    px, py = x + dx, y + dy
    if py == 0 and px == max_x - 1
      steps_to_left_of_goal = steps + 1
      break
    end
    if not visited.include?([px, py]) and viable.include?([px, py])
      queue << [px, py, steps + 1]
      visited << [px, py]
    end
  end
end

# Rest of the way is quite easy.
# ._G => .G_ => .G. => .G. => .G. => _G. => repeat
# ...    ...    .._    ._.    _..    ...
# i.e. 1 move to move the goal data (G),
# then 4 moves to move the empty space (_) back to the left of it (except for the last move of G).
puts "Least amount of steps: #{steps_to_left_of_goal + max_x + 4*(max_x - 1)}"
