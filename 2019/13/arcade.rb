input = File.read('input').strip

require 'set'
require_relative '../lib/intcode'

@game = Intcode.new(input, false)
@grid = []
@blocks = Set.new
@paddle = nil
@ball = nil

def handle_output
  while @game.has_output?
    x = @game.output
    y = @game.output

    if x == -1 and y == 0
      @score = @game.output
    else
      tile = @game.output
      case tile
      when 0
        @blocks.delete? [x,y]
      when 2
        @blocks << [x,y]
      when 3
        @paddle = x
      when 4
        @ball = x
      end
      @grid[y] ||= []
      @grid[y][x] = tile
    end
  end
 # Uncomment for (bad) graphics.
=begin
  @grid.each do |line|
    line.each do |tile|
      print case tile
            when 0
              ' '
            when 1
              "\u2588"
            when 2
              '#'
            when 3
              '='
            when 4
              'o'
            end
    end
    puts
  end
=end
end

# part 1
@game.run
handle_output

puts "#{@blocks.count} blocks found on screen"

# part 2
@game.reset
@game[0] = 2
@score = 0
@game.run do
  handle_output

  # Joystick input
  @ball <=> @paddle
end

handle_output
if not @blocks.empty?
  raise "Game Over?"
end
puts "Final score: #{@score}" 
