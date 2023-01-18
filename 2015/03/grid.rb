require_relative '../../lib/aoc_api'

input = File.read(ARGV[0] || AOC.input_file()).strip
#input = '^v^v^v^v^v'

#part 1

class Pos
  attr_reader :x, :y
  def initialize(x, y)
    @x = x
    @y = y
  end

  def ==(other)
    @x === other.x and @y === other.y
  end
  alias eql? ==

  def ===(other)
    self.class == other.class && self == other
  end

  def hash
    tmp = (@y + ((@x+1)/2))
    return @x +  ( tmp * tmp)
  end
end

x = 0
y = 0
grid = { Pos.new(x,y) => 1 }
input.each_char do |c|
  case c
  when '^'
    y -= 1
  when 'v'
    y += 1
  when '<'
    x -= 1
  when '>'
    x += 1
  else
    raise "unknown direction '#{c}'"
  end
  pos = Pos.new(x, y)
  grid[pos] = (grid[pos] || 0) + 1
end

puts "#{grid.count} houses receive at least one present"


#part 2

x = [0, 0]
y = [0, 0]
e = 0
grid = { Pos.new(0,0) => 2 }
input.each_char do |c|
  case c
  when '^'
    y[e] -= 1
  when 'v'
    y[e] += 1
  when '<'
    x[e] -= 1
  when '>'
    x[e] += 1
  else
    raise "unknown direction '#{c}'"
  end
  pos = Pos.new(x[e], y[e])
  grid[pos] = (grid[pos] || 0) + 1
  e = (e + 1) % 2
end

puts "#{grid.count} houses receive at least one present when Robo-Santa is working"


