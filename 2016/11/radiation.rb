require 'set'

file = 'input'
#file = 'example1'

input = File.read(file).strip.split("\n").map do |line|
  if line =~ /\AThe \w+ floor contains (.+)\.\z/
    contents = Regexp.last_match(1)
    if contents == 'nothing relevant'
      []
    else
      contents.split(/(?:,| and)+ /).map do |item|
        if item =~ /\Aa (\w+) generator\z/
          [ :generator, Regexp.last_match(1) ]
        elsif item =~ /\Aa (\w+)-compatible microchip\z/
          [ :chip, Regexp.last_match(1) ]
        else
          raise "Malformed item: '#{item}'"
        end
      end
    end
  else
    raise "Malformed line: '#{line}'"
  end
end

def split_list(list)
  return list.partition { |type, fuel| type == :generator }
end

def seen_key(floors, elevator)
  # All pairs are interchangeable states
  h = Hash.new(0)
  floors.each_with_index do |items, f|
    items.each do |type, fuel|
      h[fuel] |= f << (type == :generator ? 1 : 0) * floors.size
    end
  end
  return [elevator, *h.values.sort].hash
end


def min_steps_to_top(input)
  queue = [ [ input, 0, 0 ] ]
  seen = Set.new
  while not queue.empty?
    floors, elevator, steps = queue.shift

    src_gens, src_chips = split_list(floors[elevator])

    pair = src_chips.find { |_, cfuel| src_gens.any? { |_, gfuel| gfuel == cfuel } }
    if not pair.nil?
      pair = [[:generator, pair.last], pair]
    end

    unpaired_gens = src_gens.reject { |_, gfuel| src_chips.any? { |_, cfuel| cfuel == gfuel } }

    # Can't move paired generators if there are other generators on the same floor
    movable_one_gen = src_gens.size == 1 ? src_gens : unpaired_gens

    # If 2 generators on the floor => can move both
    # If 1 => combination(2) will be empty
    # If >2 => no paired generator can be moved
    movable_two_gen = src_gens.size == 2 ? [src_gens] : unpaired_gens.combination(2).to_a

    to_floors = []
    if elevator < 3
      # go up
      to_floors << elevator + 1
    end
    if elevator > 0 and not floors[0..elevator-1].all?(&:empty?)
      # go down
      to_floors << elevator - 1
    end
    moves = []
    to_floors.each do |floor|
      dest_gens, dest_chips = split_list(floors[floor])
      unpaired_chips = dest_chips.reject do |_, cfuel|
        dest_gens.any? { |_, gfuel| gfuel == cfuel }
      end

      # Can only move chips if floor has no generators or if matching generator is there
      movable_chips = dest_gens.empty? ? src_chips : src_chips.select do |_, cfuel|
        dest_gens.any? { |_, gfuel| gfuel == cfuel }
      end

      # Never try to move a mismatching chip and generator, only two chips, two gens or a matching pair
      move_two = movable_chips.combination(2).to_a
      move_one = movable_chips
      # Determine movable generators
      if unpaired_chips.empty?
        # Any generator can be moved
        move_two += movable_two_gen
        if not pair.nil?
          move_two << pair
        end
        move_one += movable_one_gen
      elsif unpaired_chips.length == 1
        # Must move the unpaired chip's generator if any generator is to be moved
        chip = unpaired_chips.first
        if not (gen = movable_one_gen.find { |_, gfuel| gfuel == chip.last }).nil?
          move_one << gen
          move_two += (movable_one_gen - gen).map { |g| [g, gen] }
        end
      elsif unpaired_chips.length == 2
        # Must move both unpaired chips' generators or no generators
        needed_gens = unpaired_chips.map { |_, fuel| [:generator, fuel] }
        if needed_gens.all? { |gen| src_gens.include?(gen) }
          move_two << needed_gens
        end
      end

      (move_two + move_one.map { |item| [item] }).each do |move|
        moves << [ move, floor, move.size * (floor - elevator) ]
      end
    end

    best_up = 0
    best_down = -Float::INFINITY
    moves.sort_by(&:last).reverse_each do |move, floor, rating|
      if rating > 0
        # If any possible move moves two items up, skip moves that only move one.
        if best_up > rating
          next
        end
        best_up = rating
      else
        # If any possible move moves one item down, skip moves that move two down.
        if best_down > rating
          next
        end
        best_down = rating
      end

      new_floors = floors.map.with_index do |content, f|
        if f == elevator
          content - move
        elsif f == floor
          content + move
        else
          content
        end
      end
      if new_floors[0..-2].all?(&:empty?)
        return steps + 1
      end
      key = seen_key(new_floors, floor)
      if not seen.include?(key)
        seen << key
        queue << [new_floors, floor, steps + 1]
      end
    end
  end
  return nil
end

# Part 1
puts "Steps to move everything to the top floor: #{min_steps_to_top(input)}"

# Part 2
new_input = input.clone
new_input[0] += ['elerium', 'dilithium'].flat_map { |fuel| [[:generator, fuel], [:chip, fuel]] }
puts "Steps to move everything to the top floor (incl. elerium and dilithium): #{min_steps_to_top(new_input)}"
