file = ARGV[0] || 'input'
#file = 'example1'

@rocks = [
  [ '####' ],

  [ '.#.',
    '###',
    '.#.' ],

  [ '..#',
    '..#',
    '###' ],

  [ '#',
    '#',
    '#',
    '#' ],

  [ '##',
    '##' ]
# Map to arrays of booleans, going up from bottom of rock
].map { |r| r.reverse.map { |l| l.chars.map { |c| c == '#' } } }

JET_TO_DX = { '<' => -1, '>' => 1 }
@jets = File.read(file).rstrip.chars.map { |c| JET_TO_DX[c] }

@chamber = []
def collission(rock, x, y)
  return true if x < 0 or x + rock.first.length > 7
  return true if y < 0
  rock.each_with_index do |line, ry|
    line.each_with_index do |cell, rx|
      if cell and (@chamber[y + ry][x + rx] rescue false)
        return true
      end
    end
  end
  return false
end

def merge_rock(rock, x, y)
  rock.each_with_index do |line, ry|
    @chamber[y + ry] ||= Array.new(7, false)
    line.each_with_index do |cell, rx|
      @chamber[y + ry][x + rx] ||= cell
    end
  end
end

def print_chamber
  @chamber.reverse_each do |line|
    print '|'
    line.each { |b| print b ? "\u2588" : ' ' }
    puts '|'
  end
  puts '+-------+'
end

dropped = 0
r = 0
j = 0
height_after = { 0 => 0 }
seen = {}
requested_drops = [
  2022,          # Part 1
  1000000000000  # Part 2
]
needed = requested_drops.max
while dropped < needed
  rock = @rocks[r]
  r = (r + 1) % @rocks.length
  x = 2
  y = @chamber.length + 3
  loop do
    dx = @jets[j]
    j = (j + 1) % @jets.length
    x += dx unless collission(rock, x + dx, y)
    break if collission(rock, x, y - 1)
    y -= 1
  end
  merge_rock(rock, x, y)
  #puts; print_chamber
  dropped += 1

  height = @chamber.length
  height_after[dropped] = height

  # Check the state based on the pattern of free spaces above the top rocks
  free_top = (0..6).map { |x| height - 1 - (@chamber.rindex { |l| l[x] } or 0) }
  state = [ r, j, free_top ].hash
  unless (last_seen = seen[state]).nil?
    last_height = height_after[last_seen]
    cycle_len = dropped - last_seen
    cycle_height = height - last_height
    requested_drops.each do |req|
      req_height = height_after[req]
      if req_height.nil?
        missing = req - dropped
        skips = missing / cycle_len
        diff = height_after[last_seen + missing % cycle_len] - last_height
        req_height = height + skips * cycle_height + diff
      end
      puts "Tower height after #{req} rocks: #{req_height}"
    end
    break
  end
  seen[state] = dropped
end
