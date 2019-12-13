input = File.read('input').strip

require 'set'
require_relative '../lib/intcode'

@graphics = false

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
      if @graphics
        Curses.setpos(0, 0)
        Curses.addstr("Score: #{@score}")
        Curses.refresh
      end
    else
      tile = @game.output
      tile_ch = ' '
      case tile
      when 0
        @blocks.delete? [x,y]
      when 1
        tile_ch = "\u2588"
      when 2
        @blocks << [x,y]
        tile_ch = "\u2592"
      when 3
        @paddle = x
        tile_ch = "\u2594"
      when 4
        @ball = x
        tile_ch = "\u2022"
      end
      @grid[y] ||= []
      @grid[y][x] = tile
      if @graphics
        Curses.setpos(y + 1, x)
        Curses.addstr(tile_ch)
        Curses.refresh
      end
    end
  end
end

# part 1
@game.run
handle_output

puts "#{@blocks.count} blocks found on screen"

# part 2
if ARGV.include?('--graphics')
  begin
    require 'curses'
    @graphics = true
  rescue LoadError
    puts 'Failed to load Curses, running without graphics'
  end
end

begin
  if @graphics
    Curses.init_screen
    Curses.curs_set(0)
  end
  @game.reset
  @game[0] = 2
  @score = 0
  @game.run do
    handle_output
    if @graphics
      sleep 0.01
    end

    # Joystick input
    @ball <=> @paddle
  end

  handle_output
ensure
  Curses.close_screen if @graphics
end

if not @blocks.empty?
  raise "Game Over?"
end
puts "Final score: #{@score}" 
