require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@cards = {}
File.read(file).rstrip.split("\n").each do |line|
  case line
  when /\ACard\s+(\d+):\s+(.+)\s+\|\s+(.+)\z/
    match = Regexp.last_match
    id = match[1].to_i
    winning = match[2].split(/\s+/).map(&:to_i)
    having = match[3].split(/\s+/).map(&:to_i)
    @cards[id] = (winning & having).length
  else
    raise "Malformed line: '#{line}'"
  end
end

# Part 1
points = 0
@cards.each_value do |matches|
  points += 2**(matches-1) if matches > 0
end
puts "Total points: #{points}"

# Part 2
@cache = {}
def play(card)
  cards = @cache[card]
  if cards.nil?
    wins = @cards[card] or 0
    cards = wins
    wins.times do |n|
      cards += play(card + 1 + n)
    end
    @cache[card] = cards
  end
  return cards
end

count = @cards.length
@cards.each_key do |card|
  count += play(card)
end
puts "Total number of scratchcards: #{count}"
