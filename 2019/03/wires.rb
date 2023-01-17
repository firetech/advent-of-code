require_relative '../../lib/aoc_api'

input = File.read(ARGV[0] || AOC.input_file()).strip.split("\n")
#input = ['R8,U5,L5,D3', 'U7,R6,D4,L4']
#input = ['R75,D30,R83,U83,L12,D49,R71,U7,L72', 'U62,R66,U55,R34,D71,R55,D58,R83']
#input = ['R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51', 'U98,R91,D20,R16,D67,R40,U7,R15,U6,R7']

#part 1
@wires = []
input.each_with_index do |line, w|
  x = 0
  y = 0
  @wires[w] = []
  line.split(',').each do |segment|
    if segment =~ /\A(U|D|L|R)(\d+)\z/
      new_x = x
      new_y = y
      dir = Regexp.last_match[1]
      length = Regexp.last_match[2].to_i
      case dir
      when 'U'
        new_y -= length
      when 'D'
        new_y += length
      when 'L'
        new_x -= length
      when 'R'
        new_x += length
      end
      @wires[w] << [x, y, new_x, new_y]
      x = new_x
      y = new_y
    else
      raise "Unknown segment: #{segment}"
    end
  end
end

@intersections = []
@wires.first.each do |x11,y11,x12,y12|
  x_min1 = [x11, x12].min
  x_max1 = [x11, x12].max
  y_min1 = [y11, y12].min
  y_max1 = [y11, y12].max
  @wires.last.each do |x21,y21,x22,y22|
    x_min2 = [x21, x22].min
    x_max2 = [x21, x22].max
    y_min2 = [y21, y22].min
    y_max2 = [y21, y22].max
    if x_min1 == x_max1 and y_min2 == y_max2 and
        x_min1 >= x_min2 and x_min1 <= x_max2 and
        y_min2 >= y_min1 and y_min2 <= y_max1
      @intersections << [x_min1, y_min2]
    elsif x_min2 == x_max2 and y_min1 == y_max1 and
        x_min2 >= x_min1 and x_min2 <= x_max1 and
        y_min1 >= y_min2 and y_min1 <= y_max2
      @intersections << [x_min2, y_min1]
    end
  end
end

distances = @intersections.map do |x,y|
  x.abs + y.abs
end.sort

if distances.first == 0
  distances.shift
end

puts "Closest intersection (manhattan): #{distances.first}"

#part 2
steps = @intersections.map do |x,y|
  this_steps = 0
  @wires.each do |segments|
    segments.each do |x1,y1,x2,y2|
      x_min = [x1, x2].min
      x_max = [x1, x2].max
      y_min = [y1, y2].min
      y_max = [y1, y2].max
      if x >= x_min and x <= x_max and
          y >= y_min and y<= y_max
        this_steps += (x - x1).abs + (y - y1).abs
        break
      else
        this_steps += (x_max - x_min).abs + (y_max - y_min).abs
      end
    end
  end
  this_steps
end.sort

if steps.first == 0
  steps.shift
end

puts "Closest intersection (steps): #{steps.first}"
