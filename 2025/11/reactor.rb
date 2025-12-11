require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@connections = {}
File.read(file).rstrip.split("\n").each do |line|
  case line
  when /\A([a-z]{3}):((?:\s+(?:[a-z]{3}))+)\z/
    @connections[Regexp.last_match(1).to_sym] = (
      Regexp.last_match(2).lstrip.split(/\s+/).map(&:to_sym)
    )
  else
    raise "Malformed line: '#{line}'"
  end
end

# Part 1
def num_routes_from(node, cache = {})
  return 1 if node == :out
  routes = cache[node]
  if routes.nil?
    routes = 0
    @connections[node].each do |next_node|
      routes += num_routes_from(next_node, cache)
    end
    cache[node] = routes
  end
  return routes
end

puts "Number or routes from 'you' to 'out': #{num_routes_from(:you)}"
