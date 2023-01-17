require_relative '../../lib/aoc_api'

input = File.read(ARGV[0] || AOC.input_file()).strip.split("\n")
#input = File.read('example').strip.split("\n")

@map = {}
@width = input.first.length
@height = input.count
input.each_with_index do |line, y|
  line.each_char.with_index do |char, x|
    if char == '#'
      @map[[x,y]] = true
    end
  end
end

# part 1
def line_of_sight(x1, y1, x2, y2)
  dx = x2 - x1
  dy = y2 - y1
  gcd = dx.gcd(dy)
  dx /= gcd
  dy /= gcd
  x = x1 + dx
  y = y1 + dy
  begin
    if x == x2 and y == y2
      return true
    end
    if @map[[x,y]]
      return false
    end
    x += dx
    y += dy
  end while (0...@width).include?(x) and (0...@height).include?(y)
  raise 'ehm?'
end

@vismap = {}
@map.each_key do |x,y|
  visible = []
  @map.each_key do |x2,y2|
    if (x2 != x or y2 != y) and line_of_sight(x, y, x2, y2)
      visible << [x2,y2]
    end
  end
  @vismap[[x,y]] = visible
end

@pos, @visible = @vismap.max_by { |pos, visible| visible.count }
puts "#{@pos.join(',')} can see #{@visible.count} other asteroids"

# part 2
def angle_between(x1,y1,x2,y2)
  atan = Math.atan2(y1 - y2, x1 - x2) * 180.0 / Math::PI
  angle = atan - 90
  while angle < 0
    angle += 360
  end
  return angle
end

@angle = {}
@visible.each do |x,y|
  @angle[[x,y]] = angle_between(*@pos, x, y)
end
@visible.sort_by! { |pos| @angle[pos] }

ans = @visible[199] # 200th

puts "200th asteroid: #{ans.join(',')} (Answer: #{ans[0] * 100 + ans[1]})"
