file = 'input'
#file = 'example1'

tiles = {}
borders = {}
border_tiles = {}
File.read(file).strip.split("\n\n").each do |block|
  lines = block.split("\n")
  header = lines.shift
  if header =~ /\ATile (\d+):\z/
    tile = Regexp.last_match(1).to_i
  else
    raise "Malformed tile header: '#{header}'"
  end
  matrix = lines.map(&:chars)
  # All borders are read clockwise
  tile_borders = [
    matrix.first.join,                            # Top border
    matrix.map { |line| line.last }.join,         # Right border
    matrix.last.reverse.join,                     # Bottom border
    matrix.map { |line| line.first }.reverse.join # Left border
  ]
  tiles[tile] = matrix[1..-2].map { |line| line[1..-2] } # Remove borders
  borders[tile] = tile_borders
  tile_borders.each_with_index do |border, edge|
    border_tiles[border] ||= []
    border_tiles[border] << [tile, edge, false]
    rev_border = border.reverse
    border_tiles[rev_border] ||= []
    border_tiles[rev_border] << [tile, edge, true]
  end
end

##########
# Part 1 #
##########
edges = border_tiles.values.select { |tiles| tiles.length == 1 }.flatten(1)
edges = edges.map { |tile, edge, flipped| [tile, edge] }.uniq # Flipped or not doesn't matter here
corners = edges.group_by { |tile, _| tile }.select { |tile, edges| edges.size > 1 }
corners = corners.map { |tile, edges| [tile, edges.map(&:last) ] }.to_h
if corners.length != 4
  raise "#{corners.length} corners found!"
end
puts "Corner product: #{corners.keys.join(' * ')} = #{corners.keys.inject(1) { |prod, x| prod * x }}"


##########
# Part 2 #
##########
# Reconstruct full image
def rotate_tile(tile, left_edge, flip)
  case left_edge
  when 0 # Top edge
    # Rotate 90 degrees clockwise
    tile = tile.map(&:reverse).transpose
  when 1 # Right edge
    # Rotate 180 degrees
    tile = tile.map(&:reverse).reverse
  when 2 # Bottom Edge
    # Rotate 270 degrees clockwise
    tile = tile.transpose.map(&:reverse)
  when 3 # Left Edge
    # Already the left side
  else
    raise "Unknown rotation: #{left_edge}"
  end
  if flip
    # Do a vertical flip
    tile = tile.reverse
  end
  return tile
end
def opposite(edge)
  (edge - 2) % 4
end
def right_neighbour(edge)
  (edge - 1) % 4
end

img = []
tile_lines = tiles.values.map(&:length).uniq
if tile_lines.length > 1
  raise "Mismatching number of lines in tiles, found #{tile_lines.join(', ')}"
end
lines_per_tile = tile_lines.first
# Choose one random corner edge to start with
tile = corners.keys.first
# Orient it as top left without flipping
left_edge, top_edge = corners[tile].sort
if left_edge == 0 and top_edge == 3
  left_edge, top_edge = top_edge, left_edge
end
flipped = false
begin
  leftmost_tile = tile
  bottom_edge = opposite(top_edge)
  next_bottom_border = borders[tile][bottom_edge].reverse

  lines = Array.new(lines_per_tile, []) # Usage of += below makes duplication here a non-issue
  begin
    next_left_border = borders[tile][opposite(left_edge)].reverse
    rotate_tile(tiles[tile], left_edge, flipped).each_with_index do |line, i|
      lines[i] += line
    end

    # Find right neighbour (if any)
    tile, left_edge, next_flipped = (border_tiles[next_left_border] or []).find { |t, e, f| t != tile }
    flipped ^= next_flipped
  end while not tile.nil?
  img += lines

  # Find bottom neighbour of leftmost tile (i.e. start next line)
  tile, top_edge, flipped = (border_tiles[next_bottom_border] or []).find { |t, e, f| t != leftmost_tile }
  if not tile.nil?
    left_edge = right_neighbour(top_edge)
    if flipped
      left_edge = opposite(left_edge)
    end
    if border_tiles[borders[tile][left_edge]].length > 1
      raise "New leftmost tile (#{tile}) has a neighbour to the left!"
    end
  end
end while not tile.nil?

# Find monsters
found = false
(0..3).to_a.product([true, false]) do |rot, flip|
  monsters = 0
  lines = rotate_tile(img, rot, flip).map(&:join)
  lines.each_with_index do |line, l|
    # Searching for middle line of monster, so skip first and last line
    next if l == 0 or l == lines.length - 1
    p = 0
    until (p = line.index(/#....##....##....###/, p)).nil?
      if lines[l-1] =~ /\A.{#{p}}..................#./ and lines[l+1] =~ /\A.{#{p}}.#..#..#..#..#..#.../
        monsters += 1
        p += 20
      else
        p += 1
      end
    end
  end
  if monsters > 0
    found = true
    roughness = lines.map { |l| l.count('#') }.inject(0) { |sum, x| sum + x } - 15 * monsters
    puts "Found #{monsters} sea monsters, water roughness: #{roughness}"
    break
  end
end
if not found
  raise "No monsters found in any orientation..."
end
