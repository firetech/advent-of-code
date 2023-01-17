require 'set'
require_relative '../../lib/aoc_api'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@catalog = {}
File.read(file).strip.split("\n").each do |line|
  adapter = line.split('/').map(&:to_i).sort
  adapter.uniq.each do |pins|
    @catalog[pins] ||= {}
    other = adapter[1 - adapter.index(pins)]
    if @catalog[pins].has_key? other
      raise "Multiple paths from #{pins} to #{other}"
    end
    @catalog[pins][other] = adapter
  end
end

@cache = {}
def traverse(from, visited = Set[])
  cache_key = [from, visited].hash
  routes = @cache[cache_key]
  if routes.nil?
    routes = []
    @catalog[from].each do |to, a|
      next if visited.include?(a)
      routes += traverse(to, visited + [a]).map do |r|
        {
          l: r[:l] + 1,
          s: r[:s] + a.sum,
        }
      end
    end
    if routes.empty?
      routes << {
        l: 0,
        s: 0,
      }
    end
    @cache[cache_key] = routes
  end
  return routes
end

bridges = traverse(0)

# Part 1
max_strength = bridges.map { |b| b[:s] }.max
puts "Strength of strongest bridge: #{max_strength}"

# Part 2
max_length = bridges.map { |b| b[:l] }.max
longest_bridges = bridges.select { |b| b[:l] == max_length }
max_long_strength = longest_bridges.map { |b| b[:s] }.max
puts "Strength of (strongest) longest bridge: #{max_long_strength}"
