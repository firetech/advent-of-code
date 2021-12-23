require 'set'
require_relative '../../lib/priority_queue'

file = 'input'
#file = 'example1'
#file = 'custom_example'

COST = { A: 1, B: 10, C: 100, D: 1000 }
WAITING_X = Set[1, 2, 4, 6, 8, 10, 11]
END_X = { A: 3, B: 5, C: 7, D: 9 }
END_Y = Set[2, 3]

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

def done?(pods)
  pods.all? do |type, list|
    list.all? { |x, y| x == END_X[type] and END_Y.include?(y) }
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

def print_state(pods)
  @map.each_with_index do |line, y|
    line.each_with_index do |m, x|
      pod = occupant(x, y, pods)
      if pod.nil?
        print m
      else
        print pod
      end
    end
    puts
  end
end

# Dijkstra adapted from 2021/15.
@cost = Hash.new(Float::INFINITY)
@cost[@pods] = 0
queue = PriorityQueue.new
queue.push(@pods, 0)
cheapest = nil
until queue.empty?
  state = queue.pop_min
  this_cost = @cost[state]

  if done?(state)
    cheapest = this_cost
    break
  end

  state.each do |type, list|
    list.each_with_index do |(x, y), i|
      moves = []
      if y == 1
        home_bottom = occupant(END_X[type], 3, state)
        # Skip pods that can't move home
        next unless ([nil, type].include?(home_bottom) and
            occupant(END_X[type], 2, state).nil?)
        moves << [END_X[type], (home_bottom.nil? ? 3 : 2)]
      else
        # Skip pods that are done
        next if y == 3 and x == END_X[type]
        next if y == 2 and x == END_X[type] and occupant(x, 3, state) == type
        # Skip pods that can't move
        next if y == 3 and not occupant(x, 2, state).nil?
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
#        puts
#        puts "Checking from:"
#        print_state(state)
#        puts "To:"
#        print_state(new_state)
#        unless free_path
#          puts "Path blocked"
#          next
#        end
#        puts "OK"
        if new_cost < @cost[new_state]
          @cost[new_state] = new_cost
          queue.push(new_state, new_cost)
        end
      end
    end
  end
end

pp cheapest
