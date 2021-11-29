@depth = 11109; @target = Complex(9, 731)
#@depth = 510; @target = Complex(10, 10)

@erosion_map = {}
def get_erosion(pos)
  value = @erosion_map[pos]
  if value.nil?
    if pos == @target
      geo_index = 0
    elsif pos.imag == 0
      # If the region's Y coordinate is 0, the geologic index is its X
      # coordinate times 16807.
      # (Also matches that the mouth (0,0) has index 0.)
      geo_index = pos.real * 16807
    elsif pos.real == 0
      # If the region's X coordinate is 0, the geologic index is its Y
      # coordinate times 48271.
      geo_index = pos.imag * 48271
    else
      # Otherwise, the region's geologic index is the result of multiplying the
      # erosion levels of the regions at X-1,Y and X,Y-1.
      geo_index = get_erosion(pos - 1) * get_erosion(pos - 1i)
    end
    # A region's erosion level is its geologic index plus the cave system's
    # depth, all modulo 20183.
    value = (geo_index + @depth) % 20183
    @erosion_map[pos] = value
  end
  return value
end

@risk_map = {}
def get_risk(pos)
  value = @risk_map[pos]
  if value.nil?
    value = get_erosion(pos) % 3
    @risk_map[pos] = value
  end
  return value
end

# Part 1
sum = 0
0.upto(@target.imag) do |y|
  pos = Complex(0, y)
  0.upto(@target.real) do
    sum += get_risk(pos)
    pos += 1
  end
end
puts "Total risk level: #{sum}"

# Part 2
require 'set'

TOOLS = {
  0 => Set[:climbing, :torch], # Rocky
  1 => Set[:climbing, nil], # Wet
  2 => Set[:torch, nil], # Narrow
}

@x_range = (0..(@target.real * 10))
@y_range = (0..(@target.imag * 10))
queue = [[Complex(0, 0), :torch, 0, 0]]
visited = Set[]
@min_time = nil
until queue.empty? or not @min_time.nil?
  pos, tool, time, switching = queue.shift
  state = [pos, tool]
  seen = visited.include?(state)
  if switching > 0
    queue << [pos, tool, time+1, switching-1] unless seen
    next
  end
  if pos == @target and tool == :torch
    @min_time = time
    break
  end
  next if seen
  visited << state
  [ -1i, 1i, -1, 1 ].each do |delta|
    npos = pos + delta
    next unless @x_range.include?(npos.real) and @y_range.include?(npos.imag)
    (TOOLS[get_risk(npos)] & TOOLS[get_risk(pos)]).each do |ntool|
      queue << [npos, ntool, time+1, (ntool == tool ? 0 : 7)]
    end
  end
end
puts "Minimum time to target (with torch): #{@min_time} minutes"
