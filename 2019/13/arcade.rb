require 'set'
require 'optparse'
require_relative '../../lib/aoc_api'
require_relative '../lib/intcode'

def usage(spacer = true)
  puts if spacer
  STDERR.puts @opts
  exit false
end

@graphics = false
@opts = OptionParser.new do |opts|
  opts.banner = "Usage: #{opts.program_name} [options] [filename]"

  opts.on('-g',
          '--graphics',
          'Enable graphics') do
    @graphics = true
  end

  opts.on('-h', '--help', 'Print this help and exit.') do
    usage(false)
  end
end

begin
  @opts.parse!(ARGV)
rescue => e
  STDERR.puts e
  usage
end

input = File.read(ARGV[0] || AOC.input_file()).strip

@game = Intcode.new(input, false)
@grid = []
@blocks = Set.new
@paddle = nil
@ball = nil

def handle_output(allow_graphics = false)
  while @game.has_output?
    x = @game.output
    y = @game.output

    if x == -1 and y == 0
      @score = @game.output
      if allow_graphics and @graphics
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
        tile_ch = "\u25C6"
      when 3
        @paddle = x
        tile_ch = "\u2580"
      when 4
        @ball = x
        tile_ch = "\u25CB"
      end
      @grid[y] ||= []
      @grid[y][x] = tile
      if allow_graphics and @graphics
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
if @graphics
  begin
    require 'curses'
  rescue LoadError
    puts 'Failed to load Curses, running without graphics'
    @graphics = false
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
    handle_output(true)
    if @graphics
      sleep 0.01
    end

    # Joystick input
    @ball <=> @paddle
  end

  handle_output(true)
ensure
  Curses.close_screen if @graphics
end

if not @blocks.empty?
  raise "Game Over?"
end
puts "Final score: #{@score}" 
