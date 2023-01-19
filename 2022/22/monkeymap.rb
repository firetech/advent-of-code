require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

FACING_DELTA = [
  [1, 0],  # Right
  [0, 1],  # Down
  [-1, 0], # Left
  [0, -1]  # Up
]

map, path = File.read(file).rstrip.split("\n\n")
@map = map.split("\n").map(&:chars)
@path = path.scan(/\d+|[LR]/).map do |step|
  if step =~ /\A[LR]\z/
    step.downcase.to_sym
  else
    step.to_i
  end
end

# Part 1
facing = 0
x = @map.first.index('.')
y = 0
@path.each do |step|
  case step
  when :l
    facing = (facing - 1) % FACING_DELTA.length
  when :r
    facing = (facing + 1) % FACING_DELTA.length
  else
    dx, dy = FACING_DELTA[facing]
    step.times do
      nx = x + dx
      ny = y + dy
      if dx != 0
        if nx < 0 or (dx < 0 and @map[ny][nx] == ' ')
          nx = @map[ny].rindex { |c| c != ' ' }
        elsif nx >= @map[ny].length or (dx > 0 and @map[ny][nx] == ' ')
          nx = @map[ny].index { |c| c != ' ' }
        end
      elsif dy != 0
        if ny < 0 or (dy < 0 and
            (nx >= @map[ny].length or @map[ny][nx] == ' '))
          ny = @map.rindex { |l| nx < l.length and l[nx] != ' ' }
        elsif ny >= @map.length or
            (dy > 0 and (nx >= @map[ny].length or @map[ny][nx] == ' '))
          ny = @map.index { |l| nx < l.length and l[nx] != ' ' }
        end
      end
      break if @map[ny][nx] == '#'
      x = nx
      y = ny
    end
  end
end
puts "Final password: #{1000*(y+1) + 4*(x+1) + facing}"

# Part 2
raise 'Part 2 is hardcoded for the shape of real inputs' if file == 'example1'
facing = 0
x = @map.first.index('.')
y = 0
@path.each do |step|
  case step
  when :l
    facing = (facing - 1) % FACING_DELTA.length
  when :r
    facing = (facing + 1) % FACING_DELTA.length
  else
    step.times do
      dx, dy = FACING_DELTA[facing]
      nf = facing
      nx = x + dx
      ny = y + dy
      # HARDCODED! :(
      # Cube layout:
      #     AB
      #     C
      #    DE
      #    F
      if dx > 0 # Right
        if ny < 50 and nx >= 150                   # B -> E
          nf = 2 # Left
          ny = 149 - ny
          nx = 99
        elsif ny >= 50 and ny < 100 and nx >= 100  # C -> B
          nf = 3 # Up
          nx = ny + 50
          ny = 49
        elsif ny >= 100 and ny < 150 and nx >= 100 # E -> B
          nf = 2 # Left
          ny = 149 - ny
          nx = 149
        elsif ny >= 150 and ny < 200 and nx >= 50  # F -> E
          nf = 3 # Up
          nx = ny - 100
          ny = 149
        end
      elsif dx < 0 # Left
        if ny < 50 and nx < 50                   # A -> D
          nf = 0 # Right
          ny = 149 - ny
          nx = 0
        elsif ny >= 50 and ny < 100 and nx < 50  # C -> D
          nf = 1 # Down
          nx = ny - 50
          ny = 100
        elsif ny >= 100 and ny < 150 and nx < 0  # D -> A
          nf = 0 # Right
          ny = 149 - ny
          nx = 50
        elsif ny >= 150 and ny < 200 and nx < 0  # F -> A
          nf = 1 # Down
          nx = ny - 100
          ny = 0
        end
      elsif dy > 0 # Down
        if nx < 50 and ny >= 200                  # F -> B
          nx = nx + 100
          ny = 0
        elsif nx >= 50 and nx < 100 and ny >= 150 # E -> F
          nf = 2 # Left
          ny = nx + 100
          nx = 49
        elsif nx >= 100 and nx < 150 and ny >= 50 # B -> C
          nf = 2 # Left
          ny = nx - 50
          nx = 99
        end
      elsif dy < 0 # Up
        if nx < 50 and ny < 100                 # D -> C
          nf = 0 # Right
          ny = nx + 50
          nx = 50
        elsif nx >= 50 and nx < 100 and ny < 0  # A -> F
          nf = 0 # Right
          ny = nx + 100
          nx = 0
        elsif nx >= 100 and nx < 150 and ny < 0 # B -> F
          nx = nx - 100
          ny = 199
        end
      end
      break if @map[ny][nx] == '#'
      facing = nf
      x = nx
      y = ny
    end
  end
end
puts "Final password (on cube): #{1000*(y+1) + 4*(x+1) + facing}"
