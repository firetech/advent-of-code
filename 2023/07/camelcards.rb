require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

CARD_ORDER_NORMAL = ['A', 'K', 'Q', 'J', 'T', '9', '8', '7', '6', '5', '4', '3', '2']
CARD_ORDER_JOKERS = ['A', 'K', 'Q', 'T', '9', '8', '7', '6', '5', '4', '3', '2', 'J']

@hands = []
File.read(file).rstrip.split("\n").each do |line|
  case line
  when /\A([#{CARD_ORDER_NORMAL.join}]{5}) (\d+)\z/
    @hands << [
      Regexp.last_match(1).chars,
      Regexp.last_match(2).to_i
    ]
  else
    raise "Malformed line: '#{line}'"
  end
end

def get_type(cards, jokers = false)
  count = cards.uniq.map { |c| [c, cards.count(c)] }.sort_by(&:last).to_h
  if jokers
    # Counting any jokers as the type we have most of should give the best hand.
    joker_count = count.delete('J')
    unless joker_count.nil?
      if count.empty?
        # Hand only contained jokers...
        count['J'] = joker_count
      else
        count[count.keys.last] += joker_count
      end
    end
  end
  case count.values
  when [5]
    return 0 # Five of a kind
  when [1, 4]
    return 1 # Four of a kind
  when [2, 3]
    return 2 # Full house
  when [1, 1, 3]
    return 3 # Three of a kind
  when [1, 2, 2]
    return 4 # Two pair
  when [1, 1, 1, 2]
    return 5 # One pair
  when [1, 1, 1, 1, 1]
    return 6 # High card
  else
    raise "Ehm? #{count.values.inspect}"
  end
end

def compare(cards1, cards2, jokers = false)
  type1 = get_type(cards1, jokers)
  type2 = get_type(cards2, jokers)
  if type1 == type2
    order = jokers ? CARD_ORDER_JOKERS : CARD_ORDER_NORMAL
    cards1.zip(cards2) do |c1, c2|
      if c1 != c2
        return order.index(c2) <=> order.index(c1)
      end
    end
    return 0
  else
    return type2 <=> type1
  end
end

def play(jokers = false)
  hand_order = @hands.sort do |(cards1, _), (cards2, _)|
    compare(cards1, cards2, jokers)
  end

  sum = 0
  hand_order.each_with_index do |(_, bid), i|
    sum += bid * (i+1)
  end
  return sum
end

# Part 1
puts "Total winnings: #{play}"

# Part 2
puts "Total winnings with jokers: #{play(true)}"
