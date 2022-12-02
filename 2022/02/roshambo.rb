file = ARGV[0] || 'input'
#file = 'example1'

MAP = {
  A: :rock,
  B: :paper,
  C: :scissors,
}

SCORE = {
  rock: 1,
  paper: 2,
  scissors: 3
}

WIN_OVER = {
  rock: :scissors,
  scissors: :paper,
  paper: :rock
}

@strategy = []
File.read(file).strip.split("\n").each do |line|
  case line
  when /\A(A|B|C) (X|Y|Z)\z/
    @strategy << [
      MAP[Regexp.last_match(1).to_sym],
      Regexp.last_match(2).to_sym
    ]
  else
    raise "Malformed line: '#{line}'"
  end
end

# Part 1
PART1_MAP = {
  X: :rock,
  Y: :paper,
  Z: :scissors
}
@part1_score = 0

# Part 2
@part2_score = 0

@strategy.each do |opp, me|
  # Part 1
  me1 = PART1_MAP[me]
  @part1_score += SCORE[me1]
  if opp == me1
    @part1_score += 3
  elsif WIN_OVER[me1] == opp
    @part1_score += 6
  end

  # Part 2
  case me
  when :X
    @part2_score += SCORE[WIN_OVER[opp]]
  when :Y
    @part2_score += SCORE[opp] + 3
  when :Z
    @part2_score += SCORE[WIN_OVER.invert[opp]] + 6
  end
end

# Part 1
puts "XYZ means RPS score: #{@part1_score}"

# Part 2
puts "XYZ means lose/draw/win score: #{@part2_score}"

