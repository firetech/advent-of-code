require_relative '../../lib/aoc_api'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@start_pos = []
File.read(file).strip.split("\n").each do |line|
  case line
  when /\APlayer (\d+) starting position: (\d+)\z/
    @start_pos[Regexp.last_match(1).to_i - 1] = Regexp.last_match(2).to_i
  else
    raise "Malformed line: '#{line}'"
  end
end

def round(pos, score, move)
  pos = ((pos + move - 1) % 10) + 1
  score += pos
  return pos, score
end

# Part 1
die = 0
rolls = 0
pos = @start_pos.clone
score = [0, 0]
player = 0  # Player 1 starts
while score.max < 1000
  move = 0
  3.times do
    move += die + 1
    die = (die + 1) % 100
  end
  rolls += 3
  pos[player], score[player] = round(pos[player], score[player], move)
  player = 1 - player
end
losing_score = score.min
puts "Losing score * die rolls in deterministic game: #{losing_score * rolls}"


# Part 2
OUTCOMES = Hash.new(0)  # Roll total => number of universes
[1,2,3].repeated_permutation(3).map(&:sum).each do |roll|
  OUTCOMES[roll] += 1
end

def hash(pos0, pos1, player, score0, score1)
  # 4 bits     4 bits       1 bit          5 bits        5 bits
  pos0 << 15 | pos1 << 11 | player << 10 | score0 << 5 | score1
end

@cache = {}
def quantum_game(pos0, pos1, player = 0, score0 = 0, score1 = 0)
  if score0 >= 21
    return [1, 0]
  elsif score1 >= 21
    return [0, 1]
  end
  state = hash(pos0, pos1, player, score0, score1)
  result = @cache[state]
  if result.nil?
    result = [0, 0]
    OUTCOMES.each do |move, move_count|
      if player == 0
        new_pos0, new_score0 = round(pos0, score0, move)
        this_result = quantum_game(new_pos0, pos1, 1, new_score0, score1)
      else
        new_pos1, new_score1 = round(pos1, score1, move)
        this_result = quantum_game(pos0, new_pos1, 0, score0, new_score1)
      end
      result.map!.with_index { |x, i| x + move_count * this_result[i] }
    end
    @cache[state] = result
  end
  return result
end

puts "Most universes won in: #{quantum_game(*@start_pos).max}"
