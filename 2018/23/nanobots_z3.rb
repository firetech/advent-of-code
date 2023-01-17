require_relative '../../lib/aoc_api'

file = ARGV[0] || AOC.input_file()
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
require 'z3'

def z3_abs(i)
  Z3.IfThenElse(i < 0, -i, i)
end

def z3_dist(x1, y1, z1, x2, y2, z2)
  z3_abs(x1 - x2) + z3_abs(y1 - y2) + z3_abs(z1 - z2)
end

@opt = Z3::Optimize.new
x = Z3.Int('x')
y = Z3.Int('y')
z = Z3.Int('z')
expr = @bots.sum do |bot|
  Z3.IfThenElse(z3_dist(bot.x,bot.y,bot.z, x,y,z) <= bot.range, 1, 0)
end
@opt.maximize(expr)
@opt.minimize(z3_dist(0,0,0, x,y,z))
@opt.check
raise "Unsatisfiable?!" unless @opt.satisfiable?
distance = @opt.model[x].to_i.abs +
           @opt.model[y].to_i.abs +
           @opt.model[z].to_i.abs
puts "Shortest distance to maximize bots in range: #{distance}"
