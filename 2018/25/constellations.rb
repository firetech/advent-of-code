require 'set'
require_relative '../../lib/aoc_api'

file = ARGV[0] || AOC.input_file()
#file = 'example1'
#file = 'example2'
#file = 'example3'
#file = 'example4'

@points = File.read(file).strip.split("\n").map do |line|
  if line =~ /\A(-?\d+),(-?\d+),(-?\d+),(-?\d+)\z/
    Regexp.last_match.to_a[1..-1].map(&:to_i)
  else
    raise "Malformed line: '#{line}'"
  end
end

def distance(a, b)
  a.zip(b).map { |aa, bb| (aa - bb).abs }.sum
end

@groups = {}
@points.each do |point|
  @groups[point] = Set[point]
end
@points.combination(2) do |a, b|
  if distance(a, b) <= 3
    a_group = @groups[a]
    b_group = @groups[b]
    if a_group != b_group
      b_group.each do |point|
        a_group << point
        @groups[point] = a_group
      end
    end
  end
end
num_groups = @groups.values.uniq { |g| g.object_id }.length
puts "Found #{num_groups} constellations"
