input = File.read('input')
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
@map[@start[1]][@start[0]] = '!'
@map[@goal[1]][@goal[0]] = '!'

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

def shortest_path(recursive)
  queue = [ [*@start, 0] ]
  distance = { queue.first => 0 }
  goal = [*@goal, 0]
  while not queue.empty? and not distance.has_key?(goal)
    from = queue.shift
    from_x, from_y, level = from
    [[0, -1], [0, 1], [-1, 0], [1, 0]].each do |delta_x, delta_y|
      x = from_x + delta_x
      y = from_y + delta_y
      to = [x, y, level]
      tile = @map[y][x]
      next unless tile == '.' or (level == 0 and tile == '!')
      next if distance.has_key?(to)
      distance[to] = distance[from] + 1
      queue << to
    end
    p_from = [from_x, from_y]
    if @pmap.has_key?(p_from)
      p_to = @pmap[p_from]
      to = p_to[0..1]
      to_level = 0
      if recursive
        to_level = level + p_to[2]
      end
      to << to_level
      if to_level >= 0 and not distance.has_key?(to)
        distance[to] = distance[from] + 1
        queue << to
      end
    end
  end
  return distance[goal]
end

# part 1
puts "Shortest path: #{shortest_path(false)} steps"

# part 2
puts "Shortest path: #{shortest_path(true)} steps"
