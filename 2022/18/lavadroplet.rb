require 'set'

file = ARGV[0] || 'input'
#file = 'example1'

@raw_voxels = []
MIN_POS = -1 # No negative numbers in input, so this is given
@max_pos = 1
File.read(file).rstrip.split("\n").each do |line|
  case line
  when /\A(\d+),(\d+),(\d+)\z/
    x = Regexp.last_match(1).to_i
    y = Regexp.last_match(2).to_i
    z = Regexp.last_match(3).to_i
    @max_pos = [@max_pos, x+1, y+1, z+1].max
    @raw_voxels << [x, y, z]
  else
    raise "Malformed line: '#{line}'"
  end
end

# Bitmasked integers are faster to hash (for usage in Set).
@pos_bits = Math.log2(@max_pos + 1).ceil
@pos_mask = (1 << @pos_bits) - 1
def to_pos(voxel)
  voxel.inject(0) { |pos, c| (pos << @pos_bits) | (c + 1) }
end
def from_pos(pos)
  voxel = []
  3.times do
    voxel.unshift((pos & @pos_mask) - 1)
    pos >>= @pos_bits
  end
  return voxel
end

@voxels = Set.new(@raw_voxels.map { |v| to_pos(v) })

def neighbours(pos)
  x, y, z = from_pos(pos)
  return [
    [x-1, y, z],
    [x+1, y, z],
    [x, y-1, z],
    [x, y+1, z],
    [x, y, z-1],
    [x, y, z+1],
  ]
end

# Part 1
sum = @voxels.sum do |v|
  neighbours(v).count { |n| not @voxels.include?(to_pos(n)) }
end
puts "Surface area of lava droplet: #{sum}"

# Part 2
queue = [to_pos([MIN_POS, MIN_POS, MIN_POS])]
visited = Set[]
area = 0
until queue.empty?
  voxel = queue.shift
  neighbours(voxel).each do |n|
    next if n.any? { |c| c < MIN_POS or c > @max_pos }
    n_pos = to_pos(n)
    if @voxels.include?(n_pos)
      area += 1
    elsif not visited.include?(n_pos)
      visited << n_pos
      queue << n_pos
    end
  end
end
puts "Exterior surface area of lava droplet: #{area}"
