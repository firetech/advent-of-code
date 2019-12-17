input = File.read('input').strip

require_relative '../lib/intcode'

begin

  @ascii = Intcode.new(input, false)
  @ascii[0] = 2
  @thread = Thread.new { @ascii.run }
  @grid = []
  line = []
  begin
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
  end while @ascii.has_output? or not @ascii.waiting_for_input?
  @height = @grid.length
  @width = @grid.first.length

  # part 1
  sum = 0
  @grid.each_with_index do |line, y|
    line.each_with_index do |tile, x|
      if tile == '#' and y > 0 and y < @height - 1 and x > 0 and x < @width - 1
        if @grid[y-1][x] == '#' and  @grid[y+1][x] == '#' and
            @grid[y][x-1] == '#' and @grid[y][x+1] == '#'
          sum += x * y
        end
      end
    end
  end
  puts "Sum of alignment parameters: #{sum}"

  # part 2
  # TODO better solution...
  input_lines = [
    'A,B,A,C,B,C,B,C,A,C',
    'L,10,R,12,R,12',
    'R,6,R,10,L,10',
    'R,10,L,10,L,12,R,6',
    'n'
  ]
  input_lines.each do |line|
    line.each_char do |chr|
      @ascii << chr.ord
    end
    @ascii << "\n".ord
  end
  last = nil
  begin
    #print last.chr unless last.nil?
    last = @ascii.output
  end while @ascii.has_output? or @ascii.running?
  puts "#{last} dust collected"

ensure
  @thread.kill
end
