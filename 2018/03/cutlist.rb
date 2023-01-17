require 'set'
require_relative '../../lib/aoc_api'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@cuts = {}
File.read(file).strip.split("\n").each do |line|
  if line =~ /\A#(\d+) @ (\d+),(\d+): (\d+)x(\d+)\z/
    _, id, x, y, w, h = Regexp.last_match.to_a.map(&:to_i)
    @cuts[id] = [ x, y, w, h ]
  else
    raise "Malformed line: '#{line}'"
  end
end

claims = {}
collisions = Set[]
good_claims = Set[]
@cuts.each do |id, (x, y, w, h)|
  good_claim = true
  (x...x+w).each do |px|
    (y...y+h).each do |py|
      key = [px, py].hash
      if claims.has_key?(key)
        collisions << key
        good_claims.delete(claims[key])
        good_claim = false
      else
        claims[key] = id
      end
    end
  end
  if good_claim
    good_claims << id
  end
end

# Part 1
puts "Squares with multiple claims: #{collisions.length}"

# Part 2
puts "Good claims: #{good_claims.map { |x| "##{x}" }.join(', ')}"
