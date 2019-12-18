input = File.read('input').strip
#input = File.read('example').strip

@maze = input.split("\n").map(&:chars)

@start = nil
@key_pos = {}
@maze.each_with_index do |line, y|
  line.each_with_index do |tile, x|
    if tile == '@'
      @start = [x, y]
    elsif tile =~ /\A[[:lower:]]\z/
      @key_pos[tile] = [x, y]
    end
  end
end

@key_to_key = {}
@key_pos.merge({'@' => @start}).each do |key, key_pos|
  queue = [ [*key_pos, []] ]
  distance = { key_pos => 0 }
  keys = {}
  while not queue.empty?
    from_x, from_y, needed_keys = queue.shift
    [[0, -1], [0, 1], [-1, 0], [1, 0]].each do |delta_x, delta_y|
      x = from_x + delta_x
      y = from_y + delta_y
      pos = [x,y]
      tile = @maze[y][x]
      next if tile == '#' or distance.has_key?(pos)
      distance[pos] = distance[[from_x,from_y]] + 1
      if tile =~ /\A[[:lower:]]\z/
        keys[tile] = {
          pos: pos,
          distance: distance[pos],
          needed_keys: needed_keys.sort
        }
      end
      if tile =~ /\A[[:upper:]]\z/
        queue << [x, y, needed_keys + [tile.downcase]]
      else
        queue << [x, y, needed_keys]
      end
    end
  end
  @key_to_key[key] = keys
end

def reachable_keys(from_key, unlocked = [])
  keys = {}
  @key_to_key[from_key].each do |key, data|
    next if unlocked.include?(key)
    if (data[:needed_keys] - unlocked).empty?
      keys[key] = data[:distance]
    end
  end
  return keys
end

@min_steps_cache = {}
def min_steps(from_key, unlocked = [])
  cache_key = [from_key, unlocked.sort.join]
  if not @min_steps_cache.has_key?(cache_key)
    keys = reachable_keys(from_key, unlocked)
    if keys.empty?
      val = 0
    else
      steps = []
      keys.each do |key, distance|
        steps << distance + min_steps(key, unlocked + [key])
      end
      val = steps.min
    end
    @min_steps_cache[cache_key] = val
  end
  return @min_steps_cache[cache_key]
end

# part 1
puts "Minimum steps: #{min_steps('@')}"
