require 'set'
require_relative '../../lib/priority_queue'

file = 'input'
#file = 'example1'
#file = 'custom_example'

COST = { A: 1, B: 10, C: 100, D: 1000 }
WAITING_X = Set[1, 2, 4, 6, 8, 10, 11]
END_X = { A: 3, B: 5, C: 7, D: 9 }

@pods = { A: [], B: [], C: [], D: [] }
@map = File.read(file).strip.split("\n").map.with_index do |line, y|
  line.chars.map.with_index do |c, x|
    case c
    when '#', ' ', '.'
      c
    when /\A[A-D]\z/
      @pods[c.to_sym] << [x, y]
      '.'
    else
      raise "Malformed line: '#{line}'"
    end
  end
end

def done?(pods, end_y)
  pods.all? do |type, list|
    list.all? { |x, y| x == END_X[type] and end_y.include?(y) }
  end
end

def occupant(x, y, pods)
  pods.each do |type, list|
    list.each do |px, py|
      if px == x and py == y
        return type
      end
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

def move_to_order(pods, end_y)
  # Dijkstra adapted from 2021/15.
  cost = Hash.new(Float::INFINITY)
  cost[pods] = 0
  queue = PriorityQueue.new
  queue.push(pods, 0)
  cheapest = nil
  until queue.empty?
    state = queue.pop_min
    this_cost = cost[state]

    if done?(state, end_y)
      return this_cost
    end

    state.each do |type, list|
      list.each_with_index do |(x, y), i|
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

          new_list = list.dup
          new_list[i] = [mx, my]
          new_state = state.merge({ type => new_list })
          new_cost = this_cost + ((x - mx).abs + (y - my).abs) * COST[type]
          if new_cost < cost[new_state]
            cost[new_state] = new_cost
            queue.push(new_state, new_cost)
          end
        end
      end
    end
  end
  return nil
end

# Part 1
puts "Least energy to order: #{move_to_order(@pods, 2..3)}"

# Part 2
new_pods = {
  A: [[7, 4], [9, 3]],
  B: [[5, 4], [7, 3]],
  C: [[5, 3], [9, 4]],
  D: [[3, 3], [3, 4]]
}
part2_pods = {}
@pods.each do |type, list|
  part2_pods[type] = list.map { |x, y| [x, (y == 3 ? 5 : y)] } + new_pods[type]
end
puts "Least energy to order (unfolded): #{move_to_order(part2_pods, 2..5)}"
