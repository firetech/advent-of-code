require_relative '../../lib/aoc_api'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@tiles = {}
File.read(file).rstrip.split("\n\n").each do |block|
  title, *body = block.split("\n")
  if not title =~ /\ATile (\d+):\z/
    raise "Malformed title: '#{title}'"
  end
  @tiles[Regexp.last_match(1).to_i] = body.map(&:chars)
end

def top_edge(body); body.first; end
def bottom_edge(body); body.last; end
def left_edge(body); body.map(&:first); end
def right_edge(body); body.map(&:last); end

# Part 1
@edge_map = Hash.new([])
@tiles.each do |id, body|
  edges = [
    top_edge(body),
    bottom_edge(body),
    left_edge(body),
    right_edge(body)
  ]
  edges.each do |edge|
    # Flip edge if it has been seen flipped first
    if @edge_map.has_key?(edge.reverse)
      raise "Shouldn't happen..." if @edge_map.has_key?(edge)
      edge = edge.reverse
    end
    @edge_map[edge] += [id]
  end
end

edges = @edge_map.values.select { |list| list.length == 1 }
edge_count = edges.group_by(&:first).transform_values(&:size)
@corners = edge_count.select { |id, count| count == 2 }.keys

product = @corners.inject(&:*)
puts "Corner product: #{@corners.join(' * ')} = #{product}"

# Part 2
def arrangements(body)
  t_body = body.transpose
  [
    body, # original
    body.reverse, # flipped vertically
    body.map(&:reverse), # flipped horizontally
    body.map(&:reverse).reverse, # both flipped (rotated 180deg)
    t_body, # ...and the same for the transposed data (flipped diagonally)
    t_body.reverse,
    t_body.map(&:reverse),
    t_body.map(&:reverse).reverse
  ]
end

# Assemble jigsaw
tiles_left = @tiles.values
start_tile = tiles_left.pop
@mat = { Complex(0, 0) => start_tile }
min_x = 0
max_x = 0
min_y = 0
max_y = 0
candidates = @mat
until tiles_left.empty?
  additions = {}
  candidates.each do |pos, body|
    tiles_left.reject! do |new_tile|
      add_data = []
      arrangements(new_tile).each do |new_body|
        if left_edge(body) == right_edge(new_body)
          add_data << pos + Complex(-1, 0)
        elsif right_edge(body) == left_edge(new_body)
          add_data << pos + Complex(1, 0)
        elsif top_edge(body) == bottom_edge(new_body)
          add_data << pos + Complex(0, -1)
        elsif bottom_edge(body) == top_edge(new_body)
          add_data << pos + Complex(0, 1)
        end
        unless add_data.empty?
          add_data << new_body
          break
        end
      end
      if add_data.empty?
        false # Keep in tiles_left
      else
        new_pos, new_body = add_data
        min_x = [min_x, new_pos.real].min
        max_x = [max_x, new_pos.real].max
        min_y = [min_y, new_pos.imag].min
        max_y = [max_y, new_pos.imag].max
        additions[new_pos] = new_body
        true # Remove from tiles_left
      end
    end
  end
  @mat.merge!(additions)
  candidates = additions
end

# Finalize image
@image = []
@hashes = 0
min_y.upto(max_y) do |y|
  1.upto(8) do |l|
    line = []
    min_x.upto(max_x) do |x|
      line.push(*@mat[Complex(x, y)][l][1..-2])
    end
    @image << line
    @hashes += line.count('#')
  end
end

# Find monsters
@monster = [
  '                  #',
  '#    ##    ##    ###',
  ' #  #  #  #  #  #'
]
@monster_width = @monster.map(&:length).max
@monster_height = @monster.size
@monster_hashes = @monster.map { |l| l.count('#') }.sum

def check_monster(image, x, y)
  @monster.each_with_index do |line, y_off|
    line.each_char.with_index do |char, x_off|
      next if char != '#'
      return false if image[y + y_off][x + x_off] != '#'
    end
  end
  return true
end

found = false
arrangements(@image).each do |image|
  monsters = 0
  (0..(image.length - @monster_height)).each do |y|
    x = 0
    while x <= image.first.length - @monster_width
      if check_monster(image, x, y)
        monsters += 1
        x += @monster_width
      else
        x += 1
      end
    end
  end

  if monsters > 0
    found = true
    roughness = @hashes - @monster_hashes * monsters
    puts "Found #{monsters} sea monsters, water roughness: #{roughness}"
    break
  end
end
if not found
  raise "No monsters found in any orientation..."
end
