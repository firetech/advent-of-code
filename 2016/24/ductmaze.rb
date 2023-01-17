require 'set'
require_relative '../../lib/aoc_api'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@maze = File.read(file).strip.split("\n")
# Find all numbers and store their positions
@poi = []
@maze.each_with_index do |line, y|
  line.each_char.with_index do |char, x|
    if char =~ /\A\d\z/
      @poi[char.to_i] = [x, y]
    end
  end
end

@poi_to_poi = {}
@poi.each_with_index do |pos, p|
  queue = [ [*pos, 0, Set[]] ]
  visited = Set[pos]
  poi = {}
  while poi.length < @poi.length and not queue.empty?
    x, y, steps, passed = queue.shift
    [[0, -1], [0, 1], [-1, 0], [1, 0]].each do |dx, dy|
      px, py = x + dx, y + dy
      if not visited.include?([px, py])
        visited << [px, py]
        case @maze[py][px]
        when /\A(\d)\z/
          pp = Regexp.last_match(1).to_i
          poi[pp] = [steps + 1, passed]
          queue << [px, py, steps + 1, passed + [pp]]
        when '.'
          queue << [px, py, steps + 1, passed]
        when '#'
          # Wall, do nothing
        else
          raise "Unexpected maze character: '#{@maze[py][px]}'"
        end
      end
    end
  end
  @poi_to_poi[p] = poi
end

def min_steps(return_to_0 = false, from_poi = 0, passed = Set[from_poi], cache = {})
  cache_key = [from_poi, passed.sort.join]
  if not cache.has_key?(cache_key)
    reachable = []
    @poi_to_poi[from_poi].each do |to_poi, (distance, on_path)|
      next if passed.include?(to_poi)
      next unless (on_path - passed).empty?
      reachable << [ to_poi, distance ]
    end
    if reachable.empty?
      val = 0
    else
      steps = []
      reachable.each do |poi, distance|
        passed_w_poi = passed + [poi]
        poi_distance = distance + min_steps(return_to_0, poi, passed_w_poi, cache)
        if return_to_0 and passed_w_poi.length == @poi.length
          poi_distance += @poi_to_poi[poi][0][0]
        end
        steps << poi_distance
      end
      val = steps.min
    end
    cache[cache_key] = val
  end
  return cache[cache_key]
end

# Part 1
puts "Shortest path passing all points of interest: #{min_steps}"

# Part 2
puts "Shortest path passing all points of interest and returning to start: #{min_steps(true)}"
