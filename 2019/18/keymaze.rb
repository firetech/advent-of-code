input = File.read('input').strip
#input = File.read('example').strip
#input = File.read('example2').strip

@maze = input.split("\n")

def parse_maze
  @start = {}
  @key_pos = {}
  @maze.each_with_index do |line, y|
    line.each_char.with_index do |tile, x|
      if tile == '@'
        @start["@#{@start.count}"] = [x, y]
      elsif tile =~ /\A[[:lower:]]\z/
        @key_pos[tile] = [x, y]
      end
    end
  end

  @key_to_key = {}
  @key_pos.merge(@start).each do |key, key_pos|
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
end

def reachable_keys(from_keys, unlocked = [])
  keys = {}
  from_keys.each_with_index do |from_key, from_index|
    @key_to_key[from_key].each do |key, data|
      next if unlocked.include?(key)
      if (data[:needed_keys] - unlocked).empty?
        keys[key] = {
          from: from_index,
          distance: data[:distance]
        }
      end
    end
  end
  return keys
end

def min_steps(from_keys, unlocked = [], cache = {})
  cache_key = [from_keys.sort.join, unlocked.sort.join]
  if not cache.has_key?(cache_key)
    keys = reachable_keys(from_keys, unlocked)
    if keys.empty?
      val = 0
    else
      steps = []
      keys.each do |key, data|
        i = data[:from]
        orig = from_keys[i]
        from_keys[i] = key
        steps << data[:distance] + min_steps(from_keys, unlocked + [key], cache)
        from_keys[i] = orig
      end
      val = steps.min
    end
    cache[cache_key] = val
  end
  return cache[cache_key]
end

# Calculate part 1
parse_maze
puts "Calculating part 1..."
puts "Minimum steps (part 1): #{min_steps(@start.keys)}"

# Modify maze for part 2
sx, sy = @start.values.first
@maze[sy-1][sx-1..sx+1] = @maze[sy+1][sx-1..sx+1] = '@#@'
@maze[sy][sx-1..sx+1] = '###'

# Calculate part 2
parse_maze
puts "Calculating part 2..."
puts "Minimum steps (part 2): #{min_steps(@start.keys)}"
