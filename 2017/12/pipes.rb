require 'set'
require_relative '../../lib/aoc_api'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@nodes = {}

File.read(file).strip.split("\n").each do |line|
  if line =~ /\A(\d+) <-> ((?:\d+(?:, )?)+)\z/
    _, node, connections = Regexp.last_match.to_a
    node = node.to_i
    connections = connections.split(', ').map(&:to_i)
    @nodes[node] = connections
  else
    raise "Malformed line: '#{line}'"
  end
end

# Part 1
def visit_group(start_node)
  visited = Set[]
  queue = [start_node]
  while not queue.empty?
    current = queue.shift
    visited << current
    @nodes[current].each do |node|
      if not visited.include?(node)
        queue << node
      end
    end
  end
  return visited
end

visited = visit_group(0)
puts "Nodes in 0's group: #{visited.length}"

# Part 2
node_group = {}
first_node = 0
visited.each { |node| node_group[node] = 0 }
while node_group.length < @nodes.length
  # Find next ungrouped node
  begin
    first_node += 1
  end while not node_group[first_node].nil?
  visit_group(first_node).each do |node|
    node_group[node] = first_node
  end
end

puts "Groups found: #{node_group.values.uniq.length}"
