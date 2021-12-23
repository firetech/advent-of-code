file = 'input'
#file = 'example1'

@input = File.read(file).strip.split("\n")

# Part 1
MISMATCH_SCORE = {
  ')' => 3,
  ']' => 57,
  '}' => 1197,
  '>' => 25137
}
score = 0
@incomplete = []
@input.each do |line|
  stack = []
  broken = false
  line.each_char do |c|
    case c
    when '('
      stack << ')'
    when '['
      stack << ']'
    when '{'
      stack << '}'
    when '<'
      stack << '>'
    else
      if c != stack.pop
        score += MISMATCH_SCORE[c]
        broken = true
        break
      end
    end
  end
  @incomplete << stack unless stack.empty? or broken
end
puts "Syntax error score: #{score}"

# Part 2
MISSING_SCORE = {
  ')' => 1,
  ']' => 2,
  '}' => 3,
  '>' => 4
}
scores = @incomplete.map do |stack|
  score = 0
  stack.reverse_each do |c|
    score = score * 5 + MISSING_SCORE[c]
  end
  score
end
scores.sort!
puts "Middle completion score: #{scores[scores.length/2]}"
