require_relative '../../lib/aoc'

input = File.read(ARGV[0] || AOC.input_file())
#input = File.read('example')
#input = File.read('example2')

@map = input.chomp("\n").split("\n")

def find_h_portals(map)
  portals = {}
  map[2..-3].each_with_index do |line, y|
    offset = 0
    while x = line.index(/[[:upper:]]{2}/, offset)
      portal = Regexp.last_match[0]
      if line[x..x+2] == "#{portal}."
        px = x+2
        level_delta = (x < line.length/2) ? 1 : -1
      elsif line[x-1..x+1] == ".#{portal}"
        px = x-1
        level_delta = (x < line.length/2) ? -1 : 1
      else
        raise "Portal #{portal} at (#{x},#{y}) is weird."
      end
      portals[portal] ||= []
      portals[portal] << [px, y+2, level_delta]
      offset = x + 1
    end
  end
  return portals
end

@portals = find_h_portals(@map)
find_h_portals(@map.map(&:chars).transpose.map(&:join)).each do |portal, points|
  @portals[portal] = (@portals[portal] or []) + points.map { |y, x, level_delta| [x, y, level_delta] }
end
@start = @portals.delete('AA').first[0..1]
@goal = @portals.delete('ZZ').first[0..1]

@pmap = {}
@portals.each do |portal, points|
  a, b = points
  a_key = a[0..1]
  raise "Duplicate portal: (#{a_key.join(',')})" if @pmap.has_key?(a_key)
  b_key = b[0..1]
  raise "Duplicate portal: (#{b_key.join(',')})" if @pmap.has_key?(b_key)
  @pmap[a_key] = b
  @pmap[b_key] = a
end

@paths = {}
([@start] + @pmap.keys).each do |base|
  base_x, base_y = base
  queue = [ base ]
  distance = { base => 0 }
  paths = {}
  while not queue.empty?
    from = queue.shift
    from_x, from_y, level = from
    [[0, -1], [0, 1], [-1, 0], [1, 0]].each do |delta_x, delta_y|
      x = from_x + delta_x
      y = from_y + delta_y
      tile = @map[y][x]
      next if tile != '.'
      to = [x, y]
      next if distance.has_key?(to)
      distance[to] = distance[from] + 1
      if to == @goal
        paths[@goal] = distance[to]
      elsif @pmap.has_key?(to)
        p_x, p_y, p_delta = @pmap[to]
        paths[[p_x, p_y]] = [distance[to] + 1, p_delta]
      else
        queue << to
      end
    end
  end
  @paths[base] = paths
end

def shortest_path(recursive)
  queue = [ [@start, 0] ]
  distance = { queue.first => 0 }
  while not queue.empty?
    from = queue.shift
    f_point, f_level = from
    paths = @paths[f_point]
    if paths.has_key?(@goal) and f_level == 0
      return distance[from] + paths[@goal]
    end
    @paths[f_point].each do |point, data|
      next if point == @goal
      p_dist, p_delta = data
      to_level = if recursive
                   to_level = f_level + p_delta
                 else
                   0
                 end
      next if to_level < 0
      to = [point, to_level]
      next if distance.has_key?(to)
      distance[to] = distance[from] + p_dist
      queue << to
    end
  end
  return nil
end

# part 1
puts "Shortest path: #{shortest_path(false)} steps"

# part 2
puts "Shortest path with recursive maze: #{shortest_path(true)} steps"
