require_relative '../../lib/aoc_api'

input = ARGV[0] || File.read(AOC.input_file()).rstrip
part1_moves = (ARGV[1] || 100).to_i
#input = '389125467'; part1_moves = 10

class Cup
  attr_reader :value
  attr_accessor :next

  def initialize(value)
    @value = value
    @next = nil
  end
end

def create_cups(digits)
  current = nil
  index = {}
  digits.each do |digit|
    digit = digit.to_i
    cup = Cup.new(digit)
    index[digit] = cup
    if not current.nil?
      current.next = cup
    end
    current = cup
  end
  first_value, first_cup = index.first
  current.next = first_cup
  return first_cup, index
end

def move_cups(current, index, moves)
  n_cups = index.size
  moves.times do
    # Pickup 3 cups
    pickup = current.next
    last_pickup = pickup.next.next
    current.next = last_pickup.next
    last_pickup.next = nil

    # Find destination cup
    step = 0
    begin
      step += 1
      dest_value = (current.value - 1 - step) % n_cups + 1
    end while dest_value == pickup.value or
      dest_value == pickup.next.value or
      dest_value == last_pickup.value
    dest_cup = index[dest_value]

    last_pickup.next = dest_cup.next
    dest_cup.next = pickup
    current = current.next
  end
  return current
end

# Part 1
current, index = create_cups(input.chars)
move_cups(current, index, part1_moves)
order = ''
current = index[1].next
while current.value != 1
  order << current.value.to_s
  current = current.next
end
puts "Cup order after cup 1 after #{part1_moves} moves: #{order}"

# Part 2
current, index = create_cups(input.chars + (10..1000000).to_a)
move_cups(current, index, 10000000)
cup1 = index[1].next
cup2 = cup1.next
puts "Product of cups following cup 1 after 10000000 moves of 1000000 cups: #{cup1.value} * #{cup2.value} = #{cup1.value * cup2.value}"
