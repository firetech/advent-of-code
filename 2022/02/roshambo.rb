file = ARGV[0] || 'input'
#file = 'example1'

@strategy = []
File.read(file).strip.split("\n").each do |line|
  case line
  when /\A(A|B|C) (X|Y|Z)\z/
    @strategy << [
      Regexp.last_match(1).ord - 'A'.ord,
      Regexp.last_match(2).ord - 'X'.ord
    ]
  else
    raise "Malformed line: '#{line}'"
  end
end

# Part 1
# me (and opp): 0 = rock, 1 = paper, 2 = scissors
@score1 = 0
@strategy.each do |opp, me|
  @score1 += me + 1
  if me == opp
    @score1 += 3
  elsif me == (opp+1)%3
    @score1 += 6
  end
end
puts "XYZ means RPS score: #{@score1}"

# Part 2
# me: 0 = lose, 1 = draw, 2 = win  (opp: see part 1)
@score2 = 0
@strategy.each do |opp, me|
  move = nil
  case me
  when 0 # lose
    move = opp + 2
  when 1 # draw
    move = opp
  when 2 # win
    move = opp + 1
  end
  #          move sc. | result sc.
  @score2 += move%3+1 + 3*me
end
puts "XYZ means lose/draw/win score: #{@score2}"
