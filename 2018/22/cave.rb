@depth = 11109; @target_x = 9; @target_y = 731
#@depth = 510; @target_x = 10; @target_y = 10

X_BITS = 16
X_MASK = (1 << X_BITS) - 1
X_RANGE = 0..X_MASK

def to_pos(x, y)
  (y << X_BITS) | x
end

def from_pos(pos)
  return (pos & X_MASK), (pos >> X_BITS)
end

@erosion_map = {}
def get_erosion(x, y)
  pos = to_pos(x, y)
  value = @erosion_map[pos]
  if value.nil?
    if x == @target_x and y == @target_y
      geo_index = 0
    elsif y == 0
      # If the region's Y coordinate is 0, the geologic index is its X
      # coordinate times 16807.
      # (Also matches that the mouth (0,0) has index 0.)
      geo_index = x * 16807
    elsif x == 0
      # If the region's X coordinate is 0, the geologic index is its Y
      # coordinate times 48271.
      geo_index = y * 48271
    else
      # Otherwise, the region's geologic index is the result of multiplying the
      # erosion levels of the regions at X-1,Y and X,Y-1.
      geo_index = get_erosion(x-1, y) * get_erosion(x, y-1)
    end
    # A region's erosion level is its geologic index plus the cave system's
    # depth, all modulo 20183.
    value = (geo_index + @depth) % 20183
    @erosion_map[pos] = value
  end
  return value
end

@risk_map = {}
def get_risk(x, y)
  pos = to_pos(x, y)
  value = @risk_map[pos]
  if value.nil?
    value = get_erosion(x, y) % 3
    @risk_map[pos] = value
  end
  return value
end


# Part 1
sum = 0
0.upto(@target_y) do |y|
  0.upto(@target_x) do |x|
    sum += get_risk(x, y)
  end
end
puts "Total risk level: #{sum}"


# Part 2
require 'set'
require_relative '../../lib/priority_queue'

NEITHER = 0
CLIMBING = 1
TORCH = 2

TOOLS = {
  0 => Set[CLIMBING, TORCH], # Rocky
  1 => Set[CLIMBING, NEITHER], # Wet
  2 => Set[TORCH, NEITHER], # Narrow
}

CHANGE_TIME = 7

def to_state(x, y, tool)
  to_pos(x, y) << 2 | tool
end

def from_state(state)
  tool = state & 0b11
  x, y = from_pos(state >> 2)
  return x, y, tool
end

target_state = to_state(@target_x, @target_y, TORCH)
start = to_state(0, 0, TORCH)
time = Hash.new(Float::INFINITY)
time[start] = 0
queue = PriorityQueue.new
queue.push(start, 0)
until queue.empty?
  state = queue.pop_min

  if state == target_state
    break
  end

  x, y, tool = from_state(state)
  this_risk = get_risk(x, y)
  this_time = time[state]
  [[-1, 0], [1, 0], [0, -1], [0, 1]].each do |delta_x, delta_y|
    nx = x + delta_x
    next unless X_RANGE.include?(nx)  # Upper limit to avoid overflow in bitmask
    ny = y + delta_y
    next if ny < 0

    # Check tool
    nrisk = get_risk(nx, ny)
    ntool = tool
    move_time = 1
    if nrisk != this_risk
      ntool = (TOOLS[nrisk] & TOOLS[this_risk]).first  # Should only have 1 item
      if ntool != tool
        move_time += CHANGE_TIME
      end
    end

    # Calculate move
    nstate = to_state(nx, ny, ntool)
    ntime = this_time + move_time
    if ntime < time[nstate]
      time[nstate] = ntime

      # A* time! :)
      # Absolutely minimum possible time to get to target state
      heuristic = (@target_x - nx).abs +
                    (@target_y - ny).abs
                    (ntool == TORCH ? 0 : CHANGE_TIME)
      queue.push(nstate, ntime + heuristic)
    end
  end
end

puts "Minimum time to target (with torch): #{time[target_state]} minutes"
