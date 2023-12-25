require 'set'
require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@neighbours = {}
File.read(file).rstrip.split("\n").each do |line|
  case line
  when /\A([a-z]+): ([a-z ]+)\z/
    node = Regexp.last_match(1)
    Regexp.last_match(2).split(' ').each do |other|
      @neighbours[node] ||= Set[]
      @neighbours[node] << other
      @neighbours[other] ||= Set[]
      @neighbours[other] << node
    end
  else
    raise "Malformed line: '#{line}'"
  end
end

# Apply the Girvan-Newman algorithm three times
# https://en.wikipedia.org/wiki/Girvan%E2%80%93Newman_algorithm
split = nil
3.times do
  betweenness = Hash.new(0)
  @neighbours.each_key do |from|
    queue = [from]
    visited = Set[]
    until queue.empty?
      node, path = queue.shift
      @neighbours[node].each do |n|
        next if visited.include?(n)
        visited << n
        edge = [node, n].sort.join(',').to_sym
        betweenness[edge] += 1
        queue << n
      end
    end
  end
  split = betweenness.sort_by(&:last).last.first.to_s.split(',')
  a, b = split
  @neighbours[a].delete(b)
  @neighbours[b].delete(a)
end

# Find the size of each subgraph
@visited = []
split.each_with_index do |start, i|
  visited = Set[start]
  @visited << visited
  queue = [start]
  until queue.empty?
    node = queue.shift
    @neighbours[node].each do |n|
      next if visited.include?(n)
      visited << n
      queue << n
    end
  end
end
unless @visited.first.disjoint?(@visited.last)
  raise 'Graph is still connected'
end
puts "Product of group sizes: #{@visited.map(&:size).inject(&:*)}"
