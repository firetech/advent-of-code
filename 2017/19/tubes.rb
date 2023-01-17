require_relative '../../lib/aoc_api'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@map = File.read(file).split("\n").map(&:chars)

dirs = {
  up:    [ 0, -1],
  down:  [ 0,  1],
  left:  [-1,  0],
  right: [ 1,  0]
}
x = @map.first.index('|')
y = 0
dir = :down
chars = ''
steps = 0
loop do
  from_x, from_y = x, y
  delta_x, delta_y = dirs[dir]
  x, y = x + delta_x, y + delta_y
  if not (0...@map.length).include?(y) or not (0...@map[y].length).include?(x)
    raise "Attempted to step outside map"
  end
  steps += 1 # In effect, we're counting _after_ stepping here, since the
             # counter also increases when stepping into the void at the end
  char = @map[y][x]
  case char
  when '+'
    dirs.each do |d, (dx, dy)|
      px, py = x + dx, y + dy
      next if px == from_x and py == from_y
      pchar = @map[py][px]
      case pchar
      when '|', '-', /[A-Z]/
        dir = d
        break
      when ' '
        # Ignore
      else
        raise "Unexpected char during turning: #{pchar}"
      end
    end
  when '|', '-'
    # Ignore, just follow the road
  when /[A-Z]/
    chars << char
  when ' '
    # End reached
    break
  else
    raise "Unexpected char: #{char}"
  end
end

# Part 1
puts "Letters encountered: #{chars}"

# Part 2
puts "Steps moved: #{steps}"
