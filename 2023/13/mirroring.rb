require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@patterns = File.read(file).rstrip.split("\n\n").map do |block|
  block.split("\n").map(&:chars)
end

def find_fold(lines, expected_diff = 0)
  1.upto(lines.count - 1) do |i|
    before, after = lines[0...i], lines[i..-1]
    len = [after.length, before.length].min
    diffs = 0
    before.last(len).zip(after.first(len).reverse) do |left, right|
      left.zip(right) do |l, r|
        diffs += 1 if l != r
        break if diffs > expected_diff
      end
      break if diffs > expected_diff
    end
    return i if diffs == expected_diff
  end
  return nil
end

sum = [0, 0]
@patterns.each do |pat|
  sum.each_index do |diffs|
    fold_y = find_fold(pat, diffs)
    if fold_y.nil?
      sum[diffs] += find_fold(pat.transpose, diffs)
    else
      sum[diffs] += 100 * fold_y
    end
  end
end

# Part 1
puts "Fold position summary: #{sum[0]}"

# Part 2
puts "Fold position summary (1 smudge): #{sum[1]}"
