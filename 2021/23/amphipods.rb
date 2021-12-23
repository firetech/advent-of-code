require 'set'
require_relative '../../lib/priority_queue'

file = 'input'
#file = 'example1'
#file = 'custom_example'

COST = { A: 1, B: 10, C: 100, D: 1000 }
WAITING_X = Set[1, 2, 4, 6, 8, 10, 11]
END_X = { A: 3, B: 5, C: 7, D: 9 }

@pods = []
@map = File.read(file).strip.split("\n").map.with_index do |line, y|
  line.chars.map.with_index do |c, x|
    case c
    when '#', ' ', '.'
      c
    when /\A[A-D]\z/
      @pods << [x, y, c.to_sym]
      '.'
    else
      raise "Malformed line: '#{line}'"
    end
  end
end

def done?(pods, end_y)
  pods.all? do |x, y, type|
    x == END_X[type] and end_y.include?(y)
  end
end

def occupant(x, y, pods)
  pods.each do |px, py, type|
    if px == x and py == y
      return type
    end
  end
  return nil
end

def print_state(pods, end_y)
  offset = 0
  @map.each_with_index do |line, y|
    times = (y == 3) ? end_y.max - 2 : 1
    times.times do |t|
      line.each_with_index do |m, x|
        pod = occupant(x, y + offset + t, pods)
        if pod.nil?
          print m
        else
          print pod
        end
      end
      puts
    end
    offset += times - 1
  end
end

TYPE_HASH = { A: 0, B: 1, C: 2, D: 3 }
def state_hash(pods)
  value = 0
  pods.each do |x, y, type|
    #                     4 bits   3 bits   2 bits
    value = value << 9 | x << 5 | y << 2 | TYPE_HASH[type]
  end
  return value
end

def heuristic(x, y, type)
  if y == 1 # Moving to hall, calculate cost of move to top of home column
    return ((x - END_X[type]).abs + 1) * COST[type]
  else # Moving from hall, no extra cost
    return 0
  end
end

def move_to_order(pods, end_y)
  # Dijkstra adapted from 2021/15, turned into A*.
  hash = state_hash(pods)
  map = { hash => pods }
  cost = Hash.new(Float::INFINITY)
  cost[hash] = 0
  queue = PriorityQueue.new
  queue.push(hash, 0)
  cheapest = nil
  until queue.empty?
    hash = queue.pop_min
    this_cost = cost[hash]
    state = map[hash]

    if done?(state, end_y)
      return this_cost
    end

    state.each_with_index do |(x, y, type), i|
      moves = []
      if y == 1 # In corridor
        # Skip pods that can't move home
        home_bottom = nil
        end_y.max.downto(end_y.min) do |ey| # Loop from bottom up
          pod = occupant(END_X[type], ey, state)
          if pod.nil?
            home_bottom = ey
            break
          elsif pod != type
            break
          end
        end
        next if home_bottom.nil?
        moves << [END_X[type], home_bottom]
      else # In a column
        # Skip pods that are done
        if x == END_X[type] # In right column
          done = true
          # Not blocking anything else that shouldn't be there
          end_y.max.downto(y+1) do |ey|
            if occupant(x, ey, state) != type
              done = false
              break
            end
          end
          next if done
        end
        # Skip pods that can't move
        blocked = false
        (y-1).downto(end_y.min) do |cy|
          unless occupant(x, cy, state).nil?
            blocked = true
            break
          end
        end
        next if blocked
        # Check all possible waiting positions
        WAITING_X.each do |wx|
          moves << [wx, 1] if occupant(wx, 1, state).nil?
        end
      end
      moves.each do |mx, my|
        free_path = true
        [x, mx].min.upto([x, mx].max) do |cx|
          next if x == cx
          next unless WAITING_X.include?(cx)
          unless occupant(cx, 1, state).nil?
            free_path = false
            break
          end
        end
        next unless free_path

        new_state = state.map.with_index do |pod, new_i|
          (new_i == i) ? [mx, my, type] : pod
        end
        new_hash = state_hash(new_state)
        map[new_hash] = new_state
        new_cost = this_cost + ((x - mx).abs + (y - my).abs) * COST[type]
        if new_cost < cost[new_hash]
          cost[new_hash] = new_cost
          queue.push(new_hash, new_cost + heuristic(mx, my, type))
        end
      end
    end
  end
  return nil
end

# Part 1
puts "Least energy to order: #{move_to_order(@pods, 2..3)}"

# Part 2
new_pods = [
  [3, 3, :D], [5, 3, :C], [7, 3, :B], [9, 3, :A],
  [3, 4, :D], [5, 4, :B], [7, 4, :A], [9, 4, :C]
]
part2_pods = @pods.map { |x, y, type| [x, (y == 3 ? 5 : y), type] } + new_pods
puts "Least energy to order (unfolded): #{move_to_order(part2_pods, 2..5)}"
