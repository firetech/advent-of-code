require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@input_map = File.read(file).rstrip.split("\n")
@width = @input_map.first.length
@height = @input_map.length

@x_bits = Math.log2(@width-1).ceil
@x_mask = (1 << @x_bits) - 1
def to_pos(x, y)
  return y << @x_bits | x
end
def from_pos(pos)
  return pos & @x_mask, pos >> @x_bits
end

@start = to_pos(1, 0)
@end = to_pos(@width-2, @height-1)

# Convert map to bidirected graph
@sloped_paths = {}
@all_paths = {}
@input_map.each_with_index do |line, y|
  line.each_char.with_index do |c, x|
    next if c == '#'
    pos = to_pos(x, y)
    [[ 0, -1], [ 1,  0], [ 0,  1], [-1,  0]].each do |dx, dy|
      nx = x + dx
      ny = y + dy
      next if ny < 0 or ny >= @height
      next if @input_map[ny][nx] == '#'
      npos = to_pos(nx, ny)

      # Part 1
      sloped_possible = case @input_map[ny][nx]
        when '^'
          dy == -1
        when '>'
          dx == 1
        when 'v'
          dy == 1
        when '<'
          dx == -1
        else
          true
      end
      @sloped_paths[pos] ||= {}
      @sloped_paths[pos][npos] = sloped_possible ? 1 : Float::INFINITY

      # Part 2
      @all_paths[pos] ||= {}
      @all_paths[pos][npos] = 1
    end
  end
end

[@sloped_paths, @all_paths].each do |paths|
  # Replace corridors with single graph edge
  paths.keys.each do |pos|
    my_paths = paths[pos]
    next if my_paths.count != 2
    a, b = my_paths.keys
    paths[a][b] = paths[a].delete(pos) + my_paths[b]
    paths[b][a] = paths[b].delete(pos) + my_paths[a]
    paths.delete(pos)
  end
  # Remove infinite paths (will affect @sloped_paths only)
  paths.each_value do |my_paths|
    my_paths.reject! { |pos, steps| steps == Float::INFINITY }
  end
end

# DFS with skipping of already visited nodes
def best_walk(paths, pos = @start, visited = Hash.new(false))
  return 0 if pos == @end
  max = nil
  visited[pos] = true
  paths[pos].each do |npos, nsteps|
    next if visited[npos]
    unless (walk = best_walk(paths, npos, visited)).nil?
      walk += nsteps
      max = walk if max.nil? or walk > max
    end
  end
  visited[pos] = false
  return max
end

# Part 1
puts "Longest hike: #{best_walk(@sloped_paths)}"

# Part 2
puts "Longest hike (with climbing): #{best_walk(@all_paths)}"
