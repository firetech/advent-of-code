require 'set'
require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

dots_str, fold_str = File.read(file).strip.split("\n\n")

max_x = 0
max_y = 0
@dots = Set[]
dots_str.split("\n").each do |line|
  case line
  when /\A(\d+),(\d+)\z/
    _, x, y = Regexp.last_match.to_a.map(&:to_i)
    @dots << [x, y]
    max_x = [max_x, x].max
    max_y = [max_y, y].max
  else
    raise "Malformed line: '#{line}'"
  end
end

dots = @dots
@folds = fold_str.strip.split("\n").map.with_index do |line, i|
  case line
  when /\Afold along ([xy])=(\d+)\z/
    axis = Regexp.last_match(1).to_sym
    value = Regexp.last_match(2).to_i
    new = Set[]
    dots.each do |x, y|
      if axis == :x and x > value
        new << [value - x + value, y]
      elsif axis == :y and y > value
        new << [x, value - y + value]
      else
        new << [x, y]
      end
    end
    dots = new
    if axis == :x
      max_x = value - 1
    elsif axis == :y
      max_y = value - 1
    end
  else
    raise "Malformed line: '#{line}'"
  end
  puts "Dots after first fold: #{dots.count}" if i == 0
end

0.upto(max_y) do |y|
  0.upto(max_x) do |x|
    if dots.include?([x, y])
      print "\u2588"
    else
      print ' '
    end
  end
  puts
end
