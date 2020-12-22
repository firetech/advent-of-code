require 'set'
require 'timeout'

file = 'input'
#file = 'example1'
#file = 'example2'

input = []
File.read(file).strip.split("\n\n").each do |block|
  lines = block.split("\n")
  header = lines.shift
  if header =~ /\APlayer (\d+):\z/
    input[Regexp.last_match(1).to_i - 1] = lines.map(&:to_i)
  else
    raise "Malformed header: '#{header}'"
  end
end

def combat(decks, recursive, cache = {})
  games = 0
  seen = Array.new(decks.length) { Set.new }
  state = decks.map(&:hash)
  game_state = state.hash
  while not cache.has_key?(game_state)
    seen.zip(state) { |list, s| list << s }

    top = decks.map(&:shift)
    if recursive and decks.zip(top).all? { |deck, n| deck.length >= n }
      round_winner, _, round_games = combat(
        decks.zip(top).map { |deck, n| deck.first(n) },
        recursive,
        cache
      )
      games += round_games
    else
      round_winner = top.index(top.max)
    end
    decks[round_winner] << top.delete_at(round_winner)
    decks[round_winner] += top

    if decks.any?(&:empty?)
      cache[game_state] = decks.index { |deck| not deck.empty? }
      break
    end

    # Checking this at the end of the loop instead of the beginning saves one hashing per game (>5000 total)
    state = decks.map(&:hash)
    if seen.zip(state).any? { |list, s| list.include?(s) }
      cache[game_state] = 0
      break
    end
  end
  winner = cache[game_state]
  return winner, decks[winner], games + 1, cache.length
end

def deck_score(deck)
  card_scores = deck.reverse.map.with_index { |val, i| val * (i + 1) }
  return card_scores.inject(0) { |sum, x| sum + x }
end

##########
# Part 1 #
##########
winner, winner_deck = combat(input.map(&:dup), false)
score = deck_score(winner_deck)
puts "Player #{winner + 1} won combat with #{score} points"

##########
# Part 2 #
##########
winner, winner_deck, games, unique = combat(input.map(&:dup), true)
score = deck_score(winner_deck)
puts "Player #{winner + 1} won recursive combat (#{games} games, #{unique} unique) with #{score} points"
