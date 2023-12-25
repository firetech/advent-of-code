require 'set'
require_relative '../../lib/aoc'
require_relative '../../lib/multicore'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@neighbours = {}
File.read(file).rstrip.split("\n").each do |line|
  case line
  when /\A([a-z]+): ([a-z ]+)\z/
    node = Regexp.last_match(1).to_sym
    Regexp.last_match(2).split(' ').each do |other|
      other = other.to_sym
      @neighbours[node] ||= Set[]
      @neighbours[node] << other
      @neighbours[other] ||= Set[]
      @neighbours[other] << node
    end
  else
    raise "Malformed line: '#{line}'"
  end
end

@to_index = @neighbours.each_key.with_index.to_h
@from_index = @to_index.invert
@bits = Math.log2(@neighbours.count).ceil
@mask = (1 << @bits) - 1
def to_key(a, b)
  a, b = b, a if b < a
  return @to_index[a] << @bits | @to_index[b]
end
def from_key(key)
  ai = key >> @bits
  bi = key & @mask
  return @from_index[ai], @from_index[bi]
end

def bfs(from)
  visited = Set[from]
  queue = [from]
  until queue.empty?
    node = queue.shift
    @neighbours[node].each do |n|
      next if visited.include?(n)
      visited << n
      yield node, n if block_given?
      queue << n
    end
  end
  return visited
end

# Apply the Girvan-Newman algorithm three times
# https://en.wikipedia.org/wiki/Girvan%E2%80%93Newman_algorithm
splits = []
stop = nil
begin
  input, output, stop = Multicore.run do |worker_in, worker_out|
    until (from, splits = worker_in[]).nil?
      splits.each do |a, b|
        @neighbours[a].delete(b)
        @neighbours[b].delete(a)
      end
      edges = []
      bfs(from) do |a, b|
        edges << to_key(a, b)
      end
      worker_out[edges]
    end
  end
  3.times do
    betweenness = Hash.new(0)
    @neighbours.each_key do |from|
      input << [from, splits]
    end
    @neighbours.count.times do
      output.pop.each do |edge|
        betweenness[edge] += 1
      end
    end
    split = from_key(betweenness.max_by(&:last).first)
    a, b = split
    @neighbours[a].delete(b)
    @neighbours[b].delete(a)
    splits << split
  end
ensure
  stop[] unless stop.nil?
end

# Find the size of each subgraph
visited = []
splits.last.each do |from|
  visited << bfs(from)
end
if visited.combination(2).any? { |a, b| not a.disjoint?(b) }
  raise 'Graph is still connected!'
end
puts "Product of group sizes: #{visited.map(&:size).inject(&:*)}"
