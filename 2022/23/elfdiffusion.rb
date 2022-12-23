require 'set'

file = ARGV[0] || 'input'
#file = 'example1'
#file = 'example2'

map = File.read(file).rstrip.split("\n").map(&:chars)
@elves = Set[]
map.each_with_index do |line, y|
  line.each_with_index do |char, x|
    if char == '#'
      @elves << [x, y]
    end
  end
end

NEIGHBOURS = [
  [-1, -1], [0, -1], [1, -1],
  [-1,  0],          [1,  0],
  [-1,  1], [0,  1], [1,  1]
]

DIRS = [
  [[[-1, -1], [ 0, -1], [ 1, -1]], [ 0, -1]],
  [[[-1,  1], [ 0,  1], [ 1,  1]], [ 0,  1]],
  [[[-1, -1], [-1,  0], [-1,  1]], [-1,  0]],
  [[[ 1, -1], [ 1,  0], [ 1,  1]], [ 1,  0]]
]

rounds = 0
dir_offset = 0
elves = @elves
begin
  moved = 0
  new_elves = Set[]
  blocked = {}
  @elves.each do |pos|
    x, y = pos
    unless NEIGHBOURS.any? { |dx, dy| @elves.include?([x+dx, y+dy]) }
      # No neighbours, no need to move
      new_elves << pos
      next
    end
    proposed = false
    DIRS.length.times do |d|
      checks, move = DIRS[(d+dir_offset) % DIRS.length]
      unless checks.any? { |dx, dy| @elves.include?([x+dx, y+dy]) }
        dx, dy = move
        new_pos = [x+dx, y+dy]
        check = blocked[new_pos]
        proposed = true
        if check.nil?
          # No one else has proposed that move yet, try to move
          blocked[new_pos] = pos
          new_elves << new_pos
          moved += 1
        elsif check != false
          # Move has been proposed by someone else, move them back
          new_elves << blocked[new_pos]
          new_elves.delete(new_pos)
          new_elves << pos
          blocked[new_pos] = false
          moved -= 1
        else
          # Move has been proposed by >2 others, just don't move
          new_elves << pos
        end
        break
      end
    end
    new_elves << pos unless proposed
  end
  @elves = new_elves
  dir_offset = (dir_offset + 1) % DIRS.length
  rounds += 1

  # Part 1
  if rounds == 10
    min_x = min_y = Float::INFINITY
    max_x = max_y = -Float::INFINITY
    @elves.each do |x, y|
      min_x = x if x < min_x
      max_x = x if x > max_x
      min_y = y if y < min_y
      max_y = y if y > max_y
    end
    free = (max_y - min_y + 1) * (max_x - min_x + 1) - @elves.count
    puts "Empty ground tiles after 10 rounds: #{free}"
  end
end while moved > 0

# Part 2
puts "First round when no elves moved: #{rounds}"
