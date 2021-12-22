require 'set'

file = 'input'
#file = 'example1'

@on_cubes = Set[]
File.read(file).strip.split("\n").each do |line|
  case line
  when /\A(on|off) x=(-?\d+)..(-?\d+),y=(-?\d+)..(-?\d+),z=(-?\d+)..(-?\d+)\z/
    x_range = Regexp.last_match(2).to_i..Regexp.last_match(3).to_i
    y_range = Regexp.last_match(4).to_i..Regexp.last_match(5).to_i
    z_range = Regexp.last_match(6).to_i..Regexp.last_match(7).to_i
    x_range.each do |x|
      next unless (-50..50).include?(x)
      y_range.each do |y|
        next unless (-50..50).include?(y)
        z_range.each do |z|
          next unless (-50..50).include?(z)
          if Regexp.last_match(1) == 'on'
            @on_cubes << [x, y, z]
          else
            @on_cubes.delete([x,y,z])
          end
        end
      end
    end
  else
    raise "Malformed line: '#{line}'"
  end
end

pp @on_cubes.length
