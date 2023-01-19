require 'set'
require_relative '../../lib/aoc'

input = File.read(ARGV[0] || AOC.input_file()).strip
#input = 'R5, L5, R5, R3'
#input = 'R8, R4, R4, R8'

dir = 0 # North
x, y = 0, 0
visited = Set[[x, y]]
revisits = []

input.split(', ').each do |instr|
  if instr =~ /\A(R|L)(\d+)\z/
    case Regexp.last_match(1)
    when 'R'
      dir = (dir + 1) % 4
    when 'L'
      dir = (dir - 1) % 4
    end
    dist = Regexp.last_match(2).to_i
    points = []
    case dir
    when 0 # North
      points = (y+1..y+dist).map { |ny| [x, ny] }
      y += dist
    when 1 # East
      points = (x+1..x+dist).map { |nx| [nx, y] }
      x += dist
    when 2 # South
      points = (y-dist..y-1).map { |ny| [x, ny] }.reverse
      y -= dist
    when 3 # West
      points = (x-dist..x-1).map { |nx| [nx, y] }.reverse
      x -= dist
    end
    points.each do |point|
      if visited.include?(point)
        revisits << point
      else
        visited << point
      end
    end
  end
end

# Part 1
puts "Shortest path: #{x.abs + y.abs} blocks"

# Part 2
rx, ry = revisits.first
puts "Distance to first revisited point: #{rx.abs + ry.abs}"
