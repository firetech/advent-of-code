require 'set'
require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'
#file = 'example2'

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

# Part 2
def num_routes_from_via(node, passed_dac = false, passed_fft = false, cache = {})
  return (passed_dac and passed_fft) ? 1 : 0 if node == :out
  cache_key = [node, passed_dac, passed_fft].hash
  routes = cache[cache_key]
  if routes.nil?
    routes = 0
    @connections[node].each do |next_node|
      routes += num_routes_from_via(
        next_node,
        (passed_dac or node == :dac),
        (passed_fft or node == :fft),
        cache
      )
    end
    cache[cache_key] = routes
  end
  return routes
end

puts "Number or routes from 'svr' to 'out', via 'dac' and 'fft': #{num_routes_from_via(:svr)}"
