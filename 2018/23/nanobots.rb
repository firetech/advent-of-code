file = 'input'
#file = 'example1'
#file = 'example2'

class Nanobot
  attr_reader :x, :y, :z, :range

  def initialize(x, y, z, range)
    @x = x
    @y = y
    @z = z
    @range = range
  end

  def distance(x, y, z)
    (@x - x).abs + (@y - y).abs + (@z - z).abs
  end

  def in_range?(bot)
    distance(bot.x, bot.y, bot.z) <= @range
  end

  def common_point?(bot)
    distance(bot.x, bot.y, bot.z) <= @range + bot.range
  end
end

@bots = File.read(file).strip.split("\n").map do |line|
  if line =~ /\Apos=<(-?\d+),(-?\d+),(-?\d+)>, r=(\d+)\z/
    Nanobot.new(*Regexp.last_match.to_a.map(&:to_i)[1..-1])
  else
    raise "Malformed line: '#{line}'"
  end
end

@strongest = @bots.max_by(&:range)
in_range = @bots.count { |bot| @strongest.in_range?(bot) }
puts "Bots in range of bot with largest range: #{in_range}"

# Part 2
require 'set'

# Build graph of all bots in range of common points
@neighbours = {}
@bots.combination(2) do |a, b|
  @neighbours[a] ||= Set[]
  @neighbours[b] ||= Set[]
  if a.common_point?(b)
    @neighbours[a] << b
    @neighbours[b] << a
  end
end

# Use the Bron-Kerborsch algorithm (with pivoting) to find the largest "clique"
# of bots (all connected to eachother).
def bron_kerbosch(possible, result = Set[], exclude = Set[])
  possible = Set.new(possible) unless possible.is_a?(Set)
  if possible.empty? and exclude.empty?
    return result
  else
    pivot = (possible + exclude).max_by { |bot| @neighbours[bot].size }
    pivot_neighbours = @neighbours[pivot]
    results = (possible - pivot_neighbours).map do |bot|
      bot_result = bron_kerbosch(
        possible & @neighbours[bot],
        result + [bot],
        exclude & @neighbours[bot]
      )
      possible.delete(bot)
      exclude << bot
      bot_result
    end
    if results.empty?
      return Set[]
    else
      return results.max_by(&:size)
    end
  end
end

clique = bron_kerbosch(@bots)

# We have the largest clique, to get the distance from the origin to the closest
# point reachable from all of the bots in the clique, we calculate the furthest
# distance from origin needed to be in range of each bot and select the largest
# of these. In other words, the furthest distance from origin needed to be in
# range of one of the bots in the clique. Given that these bots all have common
# points in range with each pair of them, this distance should be the shortest
# distance to a point in range of the most bots. No idea how many bots are in
# range, or where exactly the point is, but that wasn't asked for. ;)
distance = clique.map { |bot| bot.distance(0, 0, 0) - bot.range }.max
puts "Shortest distance to maximize bots in range: #{distance}"
