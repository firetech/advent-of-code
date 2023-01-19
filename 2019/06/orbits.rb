require_relative '../../lib/aoc'

input = File.read(ARGV[0] || AOC.input_file()).strip.split("\n")
#input = File.read('example').strip.split("\n")
#input = File.read('example2').strip.split("\n")

#part 1
@orbiters = {}
input.each do |line|
  a, b = line.split(')')
  @orbiters[a] ||= []
  @orbiters[a] << b
end

level = 1
list = [ 'COM' ]
count = 0
while not list.empty?
  next_list = []
  list.each do |body|
    orbiters = @orbiters[body]
    if not orbiters.nil?
      count += orbiters.count * level
      next_list += orbiters
    end
  end
  level += 1
  list = next_list
end

puts "#{count} direct and indirect orbits found"

#part 2
@orbits = {}
input.each do |line|
  a,b = line.split(')')
  @orbits[b] = a
end

require 'set'
from_me = Set.new
last_me = 'YOU'
from_san = Set.new
last_san = 'SAN'
loop do
  next_me = @orbits[last_me]
  if not next_me.nil?
    from_me << next_me
    last_me = next_me
  end

  next_san = @orbits[last_san]
  if not next_san.nil?
    from_san << next_san
    last_san = next_san
  end

  if next_me.nil? and next_san.nil?
    break
  end
end

puts "Transfers needed: #{(from_me ^ from_san).length}"

