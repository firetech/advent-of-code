input = File.read('input')

require_relative '../lib/intcode'

class Robot

  DIRECTIONS = [ :up, :right, :down, :left ]

  def initialize(program)
    @brain = Intcode.new(program, false)
    reset
  end

  public
  def reset
    @brain.reset
    @direction = 0
    @x = 0
    @y = 0
    @min_x = 0
    @min_y = 0
    @grid = {}
  end

  public
  def run
    @brain << camera
    @brain.run do
      paint(@brain.output)
      turn(@brain.output)
      camera
    end
  end

  public
  def paint(color)
    @grid[[@x,@y]] = color
  end

  private
  def turn(dir)
    case dir
    when 0
      @direction -= 1
    when 1
      @direction += 1
    end
    @direction %= DIRECTIONS.length
    case DIRECTIONS[@direction]
    when :up
      @y -= 1
      @min_y = [@min_y, @y].min
    when :down
      @y += 1
    when :left
      @x -= 1
      @min_x = [@min_x, @x].min
    when :right
      @x += 1
    end
  end

  private
  def camera
    return @grid[[@x,@y]] || 0
  end

  public
  def paint_count
    return @grid.count
  end

  public
  def grid
    grid = []
    @grid.each do |pos, color|
      x, y = pos
      x -= @min_x
      y -= @min_y
      grid[y] ||= []
      grid[y][x] = color
    end
    return grid
  end

end

# part 1
@robot = Robot.new(input)
@robot.run

puts "#{@robot.paint_count} panels (wrongly) painted"

# part 2
@robot.reset
@robot.paint(1) # Start on a white panel
@robot.run

puts
@robot.grid.each do |line|
  puts line.map { |panel| (panel == 1) ? "\u2588" : ' ' }.join
end
