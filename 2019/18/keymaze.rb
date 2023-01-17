require_relative '../../lib/aoc_api'

input = File.read(ARGV[0] || AOC.input_file()).strip
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
    keys = []
    while not queue.empty?
      from_x, from_y, needed_keys = queue.shift
      [[0, -1], [0, 1], [-1, 0], [1, 0]].each do |delta_x, delta_y|
        x = from_x + delta_x
        y = from_y + delta_y
        pos = [x,y]
        tile = @maze[y][x]
        next if tile == '#'
        next if distance.has_key?(pos)
        distance[pos] = distance[[from_x,from_y]] + 1
        if tile =~ /\A[[:lower:]]\z/
          keys << [ tile, needed_keys, distance[pos] ]
        end
        if tile =~ /\A[[:alpha:]]\z/
          queue << [x, y, needed_keys + [tile.downcase]]
        else
          queue << [x, y, needed_keys]
        end
      end
    end
    @key_to_key[key] = keys
  end
end

def reachable_keys(pos, unlocked = [])
  keys = []
  pos.each_with_index do |from_key, runner|
    @key_to_key[from_key].each do |key, needed_keys, distance|
      next if unlocked.include?(key)
      next unless (needed_keys - unlocked).empty?
      keys << [ runner, key, distance ]
    end
  end
  return keys
end

def min_steps(pos, unlocked = [], cache = {})
  cache_key = [pos.sort.join, unlocked.sort.join]
  if not cache.has_key?(cache_key)
    keys = reachable_keys(pos, unlocked)
    if keys.empty?
      val = 0
    else
      steps = []
      keys.each do |runner, key, distance|
        orig = pos[runner]
        pos[runner] = key
        steps << distance + min_steps(pos, unlocked + [key], cache)
        pos[runner] = orig
      end
      val = steps.min
    end
    cache[cache_key] = val
  end
  return cache[cache_key]
end

# part 1
print 'Minimum steps (part 1): '
t_start = Time.now
parse_maze
t_mid = Time.now
puts min_steps(@start.keys)
t_end = Time.now
puts '  (Parse: %.3fs, Calc: %.3fs, Total: %.3fs)' % [
  t_mid - t_start,
  t_end - t_mid,
  t_end - t_start
]

# part 2
sx, sy = @start.values.first
@maze[sy-1][sx-1..sx+1] = @maze[sy+1][sx-1..sx+1] = '@#@'
@maze[sy][sx-1..sx+1] = '###'

print 'Minimum steps (part 2): '
t_start = Time.now
parse_maze
t_mid = Time.now
puts min_steps(@start.keys)
t_end = Time.now
puts '  (Parse: %.3fs, Calc: %.3fs, Total: %.3fs)' % [
  t_mid - t_start,
  t_end - t_mid,
  t_end - t_start
]
