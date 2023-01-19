require_relative '../../lib/aoc'
require_relative '../lib/intcode'

input = File.read(ARGV[0] || AOC.input_file()).strip

begin
  @ascii = Intcode.new(input, false)
  @ascii[0] = 2 # We can solve part 1 in "part 2 mode" as well.
  @thread = Thread.new { @ascii.run }

  @grid = []
  line = []
  loop do
    output = @ascii.output.chr
    if output == "\n"
      if line.empty?
        break
      end
      @grid << line
      line = []
    else
      line << output
    end
  end
  @height = @grid.length
  @width = @grid.first.length

  # part 1
  sum = 0
  @grid.each_with_index do |line, y|
    line.each_with_index do |tile, x|
      if tile == '#' and y > 0 and y < @height - 1 and x > 0 and x < @width - 1
        if @grid[y-1][x] == '#' and @grid[y+1][x] == '#' and
            @grid[y][x-1] == '#' and @grid[y][x+1] == '#'
          sum += x * y
        end
      end
    end
  end
  puts "Sum of alignment parameters: #{sum}"

  # part 2
  @start_x = nil
  @start_y = nil
  @start_dir = nil
  robot_tiles = { '^' => :up, '>' => :right, 'v' => :down, '<' => :left }
  @grid.each_with_index do |line, y|
    val = line.each_with_index do |tile, x|
      if robot_tiles.has_key?(tile)
        @start_x = x
        @start_y = y
        @start_dir = robot_tiles[tile]
        break
      end
    end
    if val.nil?
      break
    end
  end

  def get_next(x, y, dir)
    case dir
    when :up
      y -= 1
    when :down
      y += 1
    when :left
      x -= 1
    when :right
      x += 1
    end
    return x, y
  end

  def get_tile(x, y)
    if (0...@width).include?(x) and (0...@height).include?(y)
      return @grid[y][x]
    else
      return nil
    end
  end

  @left_of = { up: :left, right: :up, down: :right, left: :down }
  @right_of = { up: :right, right: :down, down: :left, left: :up }
  x, y = @start_x, @start_y
  dir = @start_dir
  @path = []
  loop do
    count = 0
    nx, ny = get_next(x, y, dir)
    while get_tile(nx, ny) == '#'
      count += 1
      x, y = nx, ny
      nx, ny = get_next(x, y, dir)
    end
    if count > 0
      @path << count
    end

    if get_tile(*get_next(x, y, @left_of[dir])) == '#'
      dir = @left_of[dir]
      @path << 'L'
    elsif get_tile(*get_next(x, y, @right_of[dir])) == '#'
      dir = @right_of[dir]
      @path << 'R'
    else
      # nowhere to go, we're done
      break
    end
  end

  def compress(path, functions = [])
    functions.uniq!
    if functions.count > 3
      return nil
    end
    if path.empty?
      return functions
    end
    # Assume functions only contain (dir, count) pairs.
    func_length = 2
    loop do
      func = path[0...func_length]
      if func.join(',').length > 20
        break
      end
      if val = compress(path[func_length..-1], functions + [func])
        return val
      end
      func_length += 2
    end
    return nil
  end

  @main = @path.join(',')
  @functions = []
  compress(@path).each_with_index do |func, i|
    str_func = func.join(',')
    @main.gsub!(str_func, ('A'.ord + i).chr)
    @functions << str_func
  end

  input_lines = [
    @main,       # The main function
    *@functions, # Each movement function (A, B and C)
    'n'          # Continous video feed (y/n)
  ]
  input_lines.each do |line|
    line.each_char do |chr|
      @ascii << chr.ord
    end
    @ascii << "\n".ord
  end

  last = nil
  while @ascii.has_output? or @ascii.running?
    #print last.chr unless last.nil?
    last = @ascii.output
  end

  puts "#{last} dust collected"

ensure
  @thread.kill
end
