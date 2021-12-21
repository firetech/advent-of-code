file = 'input'
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
@wins = [0, 0]
states = { [0, *@start_pos, 0, 0] => 1 }
until states.empty?
  new_states = Hash.new(0)
  states.each do |(player, pos0, pos1, score0, score1), count|
    OUTCOMES.each do |move, move_count|
      total_count = count * move_count
      if player == 0
        new_pos, new_score = round(pos0, score0, move)
      else
        new_pos, new_score = round(pos1, score1, move)
      end
      if new_score >= 21
        @wins[player] += total_count
      else
        if player == 0
          new_state = [1, new_pos, pos1, new_score, score1]
        else
          new_state = [0, pos0, new_pos, score0, new_score]
        end
        new_states[new_state] += total_count
      end
    end
  end
  states = new_states
end
puts "Most universes won in: #{@wins.max}"
