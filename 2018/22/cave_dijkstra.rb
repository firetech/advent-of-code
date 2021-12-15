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
require '../../lib/priority_queue'

TOOLS = {
  0 => Set[:climbing, :torch], # Rocky
  1 => Set[:climbing, nil], # Wet
  2 => Set[:torch, nil], # Narrow
}

@x_range = (0..(@target.real * 10))
@y_range = (0..(@target.imag * 10))
start = [Complex(0,0), :torch]
dist = Hash.new(Float::INFINITY)
dist[start] = 0
queue = PriorityQueue.new
queue.push(start, 0)
visited = Set[]
until queue.empty?
  state = queue.pop_min
  visited << state

  pos, tool = state
  if pos == @target and tool == :torch
    break
  end

  this_dist = dist[state]
  [ -1i, 1i, -1, 1 ].each do |delta|
    npos = pos + delta
    next unless @x_range.include?(npos.real) and @y_range.include?(npos.imag)
    tools = TOOLS[get_risk(npos)] & TOOLS[get_risk(pos)]
    tools.each do |ntool|
      nstate = [npos, ntool]
      next if visited.include?(nstate)
      ndist = this_dist + (ntool == tool ? 1 : 8)
      stored_ndist = dist[nstate]
      if ndist < stored_ndist
        dist[nstate] = ndist
      else
        ndist = stored_ndist
      end
      queue.push(nstate, ndist)
    end
  end
end
puts "Minimum time to target (with torch): #{dist[[@target, :torch]]} minutes"
