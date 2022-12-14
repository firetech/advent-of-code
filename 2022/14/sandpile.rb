file = ARGV[0] || 'input'
#file = 'example1'

@map = {}
@min_x = @max_x = 500
@min_y = @max_y = 0
File.read(file).rstrip.split("\n").each do |line|
  segments = line.split(" -> ")
  raise "Malformed line: '#{line}'" if segments.length < 2
  last_x = nil
  last_y = nil
  segments.each do |segment|
    case segment
    when /\A(\d+),(\d+)\z/
      x = Regexp.last_match(1).to_i
      y = Regexp.last_match(2).to_i
      @min_x = [@min_x, x].min
      @max_x = [@max_x, x].max
      @min_y = [@min_y, y].min
      @max_y = [@max_y, y].max
      unless last_x.nil? or last_y.nil?
        [last_x, x].min.upto([last_x, x].max) do |px|
          [last_y, y].min.upto([last_y, y].max) do |py|
            @map[[px, py]] = '#'
          end
        end
      end
      last_x = x
      last_y = y
    else
      raise "Malformed segment: '#{segment}'"
    end
  end
end

def print_map
  @min_y.upto(@max_y) do |y|
    @min_x.upto(@max_x) do |x|
      print @map[[x, y]] || ' '
    end
    puts
  end
end

@count = 0
def fill_map(inf_floor = nil)
  loop do
    x = 500
    y = 0
    begin
      moved = false
      if @map[[x, y+1]].nil? and (inf_floor.nil? or y < inf_floor)
        y += 1
        moved = true
      elsif @map[[x-1, y+1]].nil? and (inf_floor.nil? or y < inf_floor)
        x -= 1
        y += 1
        moved = true
      elsif @map[[x+1, y+1]].nil? and (inf_floor.nil? or y < inf_floor)
        x += 1
        y += 1
        moved = true
      end
    end while moved and y < @max_y
    break if y >= @max_y or not @map[[x, y]].nil?
    @map[[x, y]] = 'o'
    @count += 1
  end
  return @count
end

# Part 1
puts "Units of sand filled before abyss: #{fill_map}"

# Part 2
@max_y += 2
puts "Units of sand to fill cave: #{fill_map(@max_y - 1)}"
