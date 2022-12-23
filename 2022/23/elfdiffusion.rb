file = ARGV[0] || 'input'
#file = 'example1'
#file = 'example2'

NEIGHBOURS = [
  [-1, -1], [0, -1], [1, -1],
  [-1,  0],          [1,  0],
  [-1,  1], [0,  1], [1,  1]
]

DIRS = [
  # [[Neighbours to check], [dx, dy]]
  [[[-1, -1], [ 0, -1], [ 1, -1]], [ 0, -1]], # North
  [[[-1,  1], [ 0,  1], [ 1,  1]], [ 0,  1]], # South
  [[[-1, -1], [-1,  0], [-1,  1]], [-1,  0]], # West
  [[[ 1, -1], [ 1,  0], [ 1,  1]], [ 1,  0]]  # East
]

C_BITS = 8 # Has buffer, largest seen in my input was 120
C_MASK = (1 << C_BITS) - 1
NEG_MASK = 0b1
def to_pos(x, y)
  x_neg = (x < 0) ? 1 : 0
  y_neg = (y < 0) ? 1 : 0
  return y.abs << (C_BITS+2) | y_neg << (C_BITS+1) | x.abs << 1 | x_neg
end
def from_pos(pos)
  x_neg = pos & NEG_MASK
  pos >>= 1
  x = pos & C_MASK
  x = -x if x_neg == 1
  pos >>= C_BITS
  y_neg = pos & NEG_MASK
  pos >>= 1
  y = pos & C_MASK
  y = -y if y_neg == 1
  return x, y
end

map = File.read(file).rstrip.split("\n").map(&:chars)
@elves = {}
map.each_with_index do |line, y|
  line.each_with_index do |char, x|
    if char == '#'
      @elves[to_pos(x, y)] = true
    end
  end
end

rounds = 0
dir_offset = 0
begin
  moved = 0
  new_elves = {}
  blocked_proposals = []
  @elves.each_key do |pos|
    x, y = from_pos(pos)
    proposed = false
    if NEIGHBOURS.any? { |dx, dy| @elves.has_key?(to_pos(x+dx, y+dy)) }
      # Neighbour found, try to move
      DIRS.length.times do |d|
        checks, move = DIRS[(d+dir_offset) % DIRS.length]
        unless checks.any? { |dx, dy| @elves.has_key?(to_pos(x+dx, y+dy)) }
          proposed = true
          dx, dy = move
          new_pos = to_pos(x+dx, y+dy)
          other = new_elves[new_pos]
          if other.nil?
            # No one else has proposed that move yet, try to move
            new_elves[new_pos] = pos
            moved += 1
          else
            # Move has been proposed by someone else
            if other != true
              # Move original proposer back
              new_elves[other] = true
              new_elves[new_pos] = true
              blocked_proposals << new_pos
              moved -= 1
            end
            # Stay put
            new_elves[pos] = true
          end
          break
        end
      end
    end
    new_elves[pos] = pos unless proposed
  end
  blocked_proposals.each do |pos|
    new_elves.delete(pos)
  end
  @elves = new_elves
  dir_offset = (dir_offset + 1) % DIRS.length
  rounds += 1

  # Part 1
  if rounds == 10
    min_x = min_y = Float::INFINITY
    max_x = max_y = -Float::INFINITY
    @elves.each_key do |pos|
      x, y = from_pos(pos)
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
