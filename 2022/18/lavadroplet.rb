require 'set'

file = ARGV[0] || 'input'
#file = 'example1'

@voxels = Set[]
min_x = max_x = 0
min_y = max_y = 0
min_z = max_z = 0
File.read(file).rstrip.split("\n").each do |line|
  case line
  when /\A(\d+),(\d+),(\d+)\z/
    x = Regexp.last_match(1).to_i
    y = Regexp.last_match(2).to_i
    z = Regexp.last_match(3).to_i
    min_x = [min_x, x].min
    max_x = [max_x, x].max
    min_y = [min_y, y].min
    max_y = [max_y, y].max
    min_z = [min_z, z].min
    max_z = [max_z, z].max
    @voxels << [x, y, z]
  else
    raise "Malformed line: '#{line}'"
  end
end

def neighbours(x,y,z)
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
sum = @voxels.sum(0) do |x, y, z|
  neighbours(x,y,z).count { |v| not @voxels.include?(v) }
end

puts "Surface area of lava droplet: #{sum}"

# Part 2
all_voxels = Set[]
(min_x-1..max_x+1).each do |x|
  (min_y-1..max_y+1).each do |y|
    (min_z-1..max_z+1).each do |z|
      all_voxels << [x, y, z]
    end
  end
end

# Find enclosed cubes by excluding all non-enclosed empty cubes
empty = all_voxels - @voxels
queue = [[min_x-1, min_y-1, min_z-1]]
until queue.empty?
  voxel = queue.shift
  if empty.delete?(voxel)
    queue.push(*neighbours(*voxel))
  end
end

empty_sum = empty.sum(0) do |x, y, z|
  neighbours(x,y,z).count { |v| not empty.include?(v) }
end

puts "Exterior surface area of lava droplet: #{sum - empty_sum}"
