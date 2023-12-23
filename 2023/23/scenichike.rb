require 'set'
require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@map = File.read(file).rstrip.split("\n")
@width = @map.first.length
@height = @map.length

@x_bits = Math.log2(@width-1).ceil
@x_mask = (1 << @x_bits) - 1
def to_pos(x, y)
  return y << @x_bits | x
end
def from_pos(pos)
  return pos & @x_mask, pos >> @x_bits
end

@start = to_pos(1, 0)
@end = to_pos(@width-2, @height-1)

queue = [[@start, Set[@start]]]
length = Hash.new(0)
until queue.empty?
  pos, path = queue.shift
  next if pos == @end

  x, y = from_pos(pos)
  this_length = length[pos]
  deltas = case @map[y][x]
    when '^'
      [[ 0, -1]]
    when '>'
      [[ 1,  0]]
    when 'v'
      [[ 0,  1]]
    when '<'
      [[-1,  0]]
    else
      [[ 0, -1], [ 1,  0], [ 0,  1], [-1,  0]]
  end
  deltas.each do |dx, dy|
    nx = x + dx
    ny = y + dy
    next if ny < 0 # Don't leave the area
    npos = to_pos(nx, ny)
    next if @map[ny][nx] == '#'
    next if path.include?(npos)

    nlength = this_length + 1
    if nlength > length[npos]
      length[npos] = nlength
      queue << [npos, path + [npos]]
    end
  end
end
pp length[@end]
