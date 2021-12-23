require_relative '../../lib/priority_queue'

file = 'input'
#file = 'example1'
#file = 'custom_example'

COST = { A: 1, B: 10, C: 100, D: 1000 }
WAITING_X = [1, 2, 4, 6, 8, 10, 11]
END_X = { A: 3, B: 5, C: 7, D: 9 }

@amphipods = []
File.read(file).strip.split("\n").each_with_index do |line, y|
  line.each_char.with_index do |c, x|
    case c
    when '#', ' ', '.'
      # Ignore
    when /\A[A-D]\z/
      @amphipods << [x, y, c.to_sym]
    else
      raise "Malformed line: '#{line}'"
    end
  end
end

TYPE_HASH = { A: 0, B: 1, C: 2, D: 3 }
def state_hash(amphipods)
  value = 0
  amphipods.each do |x, y, type|
    #                    4 bits   3 bits   2 bits
    value = value << 9 | x << 5 | y << 2 | TYPE_HASH[type]
  end
  return value
end

def min_done_cost(amphipods)
  # Minimum cost to move all amphipods to their column (ignoring collisions)
  cost = 0
  amphipods.each do |x, y, type|
    home = END_X[type]
    next if x == home
    # Move to corridor, to above home column and down into it
    cost += ((y - 1).abs + (x - home).abs + 1) * COST[type]
  end
  return cost
end

def move_to_order(amphipods, end_y)
  # Dijkstra adapted from 2021/15, turned into A*.
  hash = state_hash(amphipods)
  map = { hash => amphipods }
  cost = Hash.new(Float::INFINITY)
  cost[hash] = 0
  queue = PriorityQueue.new
  queue.push(hash, 0)
  until queue.empty?
    hash = queue.pop_min
    this_cost = cost[hash]
    state = map[hash]

    if min_done_cost(state) == 0
      return this_cost
    end

    state.each_with_index do |(x, y, type), i|
      moves = []
      home = END_X[type]
      if y == 1 # In corridor
        # Find lowest free position in home column
        home_has_other = false
        home_y = end_y.max
        state.each do |other_x, other_y, other_type|
          next if other_x != home
          if other_type != type
            # Can't move home yet, other type is in home column
            home_has_other = true
            break
          end
          home_y = other_y - 1 if other_y <= home_y
        end
        next if home_has_other
        # Target lowest free position in home column
        moves << [home, home_y]
      else # In a column
        # Skip amphipods that are done or can't move
        done = (x == home) # In right column
        blocked = false
        home_free = true
        home_pos = end_y.max
        state.each do |other_x, other_y, other_type|
          next if other_x != x
          if other_y < y
            # Another amphipod is above
            blocked = true
            break
          elsif done and other_type != type and other_y > y
            # This amphipod is home, but an amphipod of wrong type is below
            done = false
          end
        end
        next if done or blocked
        # Target all possible corridor positions
        WAITING_X.each { |wx| moves << [wx, 1] }
      end
      moves.each do |mx, my|
        # Check if any other amphipod is in the way in the corridor
        free_path = true
        x_limits = [x, mx]
        x_min = x_limits.min
        x_max = x_limits.max
        state.each do |other_x, other_y, _|
          next if other_y != 1 # Other is not in corridor
          next if other_x == x # Other is the moving amphipod
          if other_x >= x_min and other_x <= x_max
            # Other amphipod is in the way
            free_path = false
            break
          end
        end
        next unless free_path

        # Move is possible, calculate cost and add to queue (A*).
        new_state = state.map.with_index do |pod, new_i|
          (new_i == i) ? [mx, my, type] : pod
        end
        new_hash = state_hash(new_state)
        new_cost = this_cost + ((x - mx).abs + (y - my).abs) * COST[type]
        if new_cost < cost[new_hash]
          map[new_hash] = new_state
          cost[new_hash] = new_cost
          queue.push(new_hash, new_cost + min_done_cost(new_state))
        end
      end
    end
  end
  return nil
end

# Part 1
puts "Least energy to order: #{move_to_order(@amphipods, 2..3)}"

# Part 2
part2_amphipods = [
  [3, 3, :D], [5, 3, :C], [7, 3, :B], [9, 3, :A],
  [3, 4, :D], [5, 4, :B], [7, 4, :A], [9, 4, :C]
] + @amphipods.map { |x, y, type| [x, (y == 3 ? 5 : y), type] }
puts "Least energy to order (unfolded): #{move_to_order(part2_amphipods, 2..5)}"
