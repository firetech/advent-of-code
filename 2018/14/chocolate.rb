@input = 633601
#@input = 9
#@input = 2018
#@input = 51589
#@input = 59414

@input_digits = @input.digits.reverse
@input_length = @input_digits.length
@input_index = 0
@score_index = nil
def score_match(offset)
  if @scores[offset] == @input_digits[@input_index]
    @input_index += 1
    if @input_index == @input_length
      @score_index = offset - @input_index + 1
    end
    return true
  end
  return false
end

def check_score(offset)
  unless score_match(offset)
    check_offset = offset - @input_index + 1
    @input_index = 0
    while check_offset <= offset
      if score_match(check_offset)
        check_offset += 1
      elsif @input_index > 0
        check_offset = check_offset - @input_index + 1
        @input_index = 0
      else
        check_offset += 1
      end
    end
  end
end

@scores = [3, 7]
elves = [0, 1]
length = 2
target = @input + 10
while length < target or @score_index.nil?
  elf_scores = elves.map { |e| @scores[e] }
  digits = elf_scores.sum.digits.reverse
  prev_length = length
  digits.each do |d|
    @scores << d
    check_score(length) if @score_index.nil?
    length += 1
  end
  if prev_length < target and length >= target
    # Part 1
    puts "Ten recipies after #{@input} receipts: #{@scores[@input, 10].join}"
  end
  elves.map! { |e, i| (e + 1 + @scores[e]) % length }
end


# Part 2
puts "Receipts before #{@input}: #{@score_index}"
