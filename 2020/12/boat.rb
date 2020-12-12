file = 'input'
#file = 'example1'

input = File.read(file).strip.split("\n").map do |instr|
  if instr =~ /\A([NSEWLRF])(\d+)\z/
    [ Regexp.last_match(1).to_sym, Regexp.last_match(2).to_i ]
  else
    raise "Malformatted instruction: '#{instr}'"
  end
end

def normalize_dir(dir)
  while dir < 0
    dir += 360
  end
  while dir >= 360
    dir -= 360
  end
  return dir
end

#part 1
dir = 0
x = 0
y = 0
input.each do |move, amount|
  if move == :F
    move = case dir
    when 0
      :E
    when 90
      :N
    when 180
      :W
    when 270
      :S
    else
      raise "Unknown direction: #{dir}"
    end
  end

  case move
  when :N
    y += amount
  when :S
    y -= amount
  when :E
    x += amount
  when :W
    x -= amount
  when :L
    dir = normalize_dir(dir + amount)
  when :R
    dir = normalize_dir(dir - amount)
  end
end
puts "Manhattan distance sum (direction-based): #{x.abs + y.abs}"


#part 2
def rotate_waypoint(x, y, dir)
  case normalize_dir(dir)
  when 90
    return -y, x
  when 180
    return -x, -y
  when 270
    return y, -x
  end
  raise "Unhandled dir: #{normalize_dir(dir)}"
end

wpx = 10
wpy = 1
x = 0
y = 0
input.each do |move, amount|
  case move
  when :N
    wpy += amount
  when :S
    wpy -= amount
  when :E
    wpx += amount
  when :W
    wpx -= amount
  when :L
    wpx, wpy = rotate_waypoint(wpx, wpy, amount)
  when :R
    wpx, wpy = rotate_waypoint(wpx, wpy, -amount)
  when :F
    x += wpx * amount
    y += wpy * amount
  end
end
puts "Manhattan distance sum (waypoint-based): #{x.abs + y.abs}"

