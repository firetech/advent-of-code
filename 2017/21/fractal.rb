require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
iters = ARGV.length > 1 ? ARGV[1..-1].map(&:to_i) : [5, 18]

#file = 'example1'; iters = [2]

def rotate_tile(tile, rot, flip)
  case rot
  when 0 # 0 degrees
    # Don't rotate
  when 1 # 90 degrees (clockwise)
    tile = tile.transpose.map(&:reverse)
  when 2 # 180 degrees
    tile = tile.map(&:reverse).reverse
  when 3 # 270 degrees (clockwise)
    tile = tile.map(&:reverse).transpose
  else
    raise "Unknown rotation: #{left_edge}"
  end
  if flip
    # Do a vertical flip
    tile = tile.reverse
  end
  return tile
end

@mapping = {}
File.read(file).strip.split("\n").each do |line|
  if line =~ /\A((?:[.#]+\/?)+) => ((?:[.#]+\/?)+)\z/
    from = Regexp.last_match(1).split('/').map(&:chars)
    to = Regexp.last_match(2).split('/').map(&:chars)
    (0..3).to_a.product([false, true]) do |rot, flip|
      @mapping[rotate_tile(from, rot, flip)] = to
    end
  else
    raise "Malformed line: '#{line}'"
  end
end

start_tile = <<TILE
.#.
..#
###
TILE
START_TILE = start_tile.split("\n").map(&:chars)

def split(block, split_size)
  splits = []
  block.each_slice(split_size) do |line_group|
    group_splits = []
    line_group.each do |line|
      line.each_slice(split_size).with_index do |split, s|
        group_splits[s] ||= []
        group_splits[s] << split
      end
    end
    splits << group_splits
  end
  return splits
end

def iterate(block)
  size = block.length
  if size % 2 == 0
    split_size = 2
    map_size = 3
  elsif size % 3 == 0
    split_size = 3
    map_size = 4
  else
    raise "Bad size: #{size}"
  end
  new_size = (size / split_size) * map_size
  new = []
  split(block, split_size).each do |split_line|
    new_lines = []
    split_line.each do |split|
      map_split = @mapping[split]
      raise "Mapping not found" if map_split.nil?
      map_split.each_with_index do |map_line, l|
        new_lines[l] ||= []
        new_lines[l] += map_line
      end
    end
    new += new_lines
  end
  return new
end

# For a 3x3 block, iterate 3 times, giving 9 new 3x3 blocks.
# Each of these blocks can then be given the same procedure individually.
# Return a mapping table of the number of occurences among the 9 new blocks.
@map3_cache = {}
def map3(block)
  unless @map3_cache.include?(block)
    grid = iterate(iterate(iterate(block)))
    map = Hash.new(0)
    split(grid, 3).each do |split_line|
      split_line.each do |split|
        map[split] += 1
      end
    end
    @map3_cache[block] = map
  end
  return @map3_cache[block]
end

iters.each do |iter|
  count = { START_TILE => 1 }
  # Use the fast 3x3 => 9 3x3 calculation as many times as possible.
  (iter / 3).times do
    next_count = Hash.new(0)
    count.each do |block, block_count|
      map3(block).each do |to_block, to_count|
        next_count[to_block] += block_count * to_count
      end
    end
    count = next_count
  end
  # Calculate the rest of the steps individually.
  (iter % 3).times do
    next_count = Hash.new(0)
    count.each do |block, block_count|
      next_count[iterate(block)] += block_count
    end
    count = next_count
  end

  total = 0
  count.each do |block, block_count|
    total += block.join.count('#') * block_count
  end
  puts "#{total} active squares after #{iter} iterations"
end
