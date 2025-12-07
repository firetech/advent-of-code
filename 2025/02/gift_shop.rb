require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@ranges = []
File.read(file).rstrip.split(",").each do |range|
  case range
  when /\A(\d+)-(\d+)\z/
    @ranges << [Regexp.last_match(1), Regexp.last_match(2)]
  else
    raise "Malformed range: '#{range}'"
  end
end

# Standard formula for sum of all numbers 1 to n (inclusive).
def sum_first_n(n)
  return n * (n + 1) / 2
end

# Sum of all numbers from min to max (inclusive).
def sum_range(min, max)
  return sum_first_n(max) - sum_first_n(min - 1)
end

# Sum of all numbers with repeated patterns from min_s (as a string) to max_s
# (as a string), with the total number length of num_digits and a repeated
# pattern length of pat_len.
def sum_rep(min_s, max_s, num_digits, pat_len)
  reps, rest = num_digits.divmod(pat_len)
  return 0 if rest != 0  # num_digits can't be evenly split by pat_len.

  min = min_s.to_i
  max = max_s.to_i

  pat_pow = 10**pat_len  # E.g. pat_len=2 -> 100
  pat_start = pat_pow / 10  # E.g. pat_len=2 -> 10
  pat_end = pat_pow - 1  # E.g. pat_len=2 -> 99

  # E.g. pat_len=3, reps=3 -> 10000 (123456 / 10000 = 12)
  pat_div = pat_pow ** (reps - 1)
  # E.g. pat_len=2, reps=3 -> 10101 (12 * 10101 = 121212)
  pat_mul = (pat_div*pat_pow - 1) / (pat_pow - 1)
  #       == (10**(pat_len*reps) - 1) / (10**pat_len - 1)
  # E.g.  == 999999 / 99 == 10101 (for pat_len=2, reps=3)

  # Get the smallest repeatable pattern that fits in the range.
  if num_digits > min_s.length
    # num_digits is above the range's minimum number of digits, so the smallest
    # number with the given pattern length (i.e. pat_start) will fit.
    pat_min = pat_start
  else
    # Calculate the smallest repeatable pattern.
    # E.g:
    # - min=121212, pat_len=2, reps=3 -> 12 (since 121212 >= 121212)
    # - min=121213, pat_len=2, reps=3 -> 13 (since 121212 < 121213)
    pat_min = min / pat_div
    pat_min += 1 if (pat_min * pat_mul) < min
  end

  # Get the largest repeateable pattern that fits in the range.
  if num_digits < max_s.length
    # num_digits is below the range's maximum number of digits, so the largest
    # number with the given pattern length (i.e. pat_end) will fit.
    pat_max = pat_end
  else
    # Calculate the largest repeatable pattern.
    # E.g:
    # - max=121212, pat_len=2, reps=3 -> 12 (since 121212 <= 121212)
    # - max=121211, pat_len=2, reps=3 -> 11 (since 121212 > 121211)
    pat_max = max / pat_div
    pat_max -= 1 if (pat_max * pat_mul) > max
  end

  return 0 if pat_min > pat_max  # No possible numbers are in range.
  return pat_min * pat_mul if pat_min == pat_max  # Only one possible number.

  # Get the sum of all the possible patterns of the given length. This sum
  # multiplied by pat_mul calculated above gives the sum of all the numbers that
  # these patterns create.
  return sum_range(pat_min, pat_max) * pat_mul
end

@repeated_once = 0  # Part 1
@repeated_mult = 0  # Part 2
@ranges.each do |min_s, max_s|
  # Loop through all possible number lengths that fit in this range.
  min_s.length.upto(max_s.length) do |num_digits|
    pat_sums = {}
    sum = 0
    max_pat_len = num_digits / 2
    # Loop through all possible pattern lengths that fit in num_digits.
    1.upto(max_pat_len) do |pat_len|
      # Get and save the sum of all pattern numbers with this number of digits
      # and this pattern length
      pat_sum = sum_rep(min_s, max_s, num_digits, pat_len)
      pat_sums[pat_len] = pat_sum

      # If any pattern numbers could be created
      if pat_sum > 0
        sum += pat_sum  # Add this sum to our total...
        1.upto(pat_len - 1) do |factor_len|
          # ...and remove any sums with a pattern length that's a factor of this
          # pattern length from the total, to avoid double counting numbers.
          # (E.g. 111111 is a repeated patterns with pattern lengths 1, 2 and 3,
          # and should thus be removed from the totals for lengths 2 and 3,
          # while still including e.g. 121212 and 123123 in the total.)
          sum -= pat_sums[factor_len] if pat_len % factor_len == 0
        end
      end
    end
    # Part 1 (add the sum of numbers with the max length if this splits the
    # total length evenly).
    if max_pat_len + max_pat_len == num_digits
      @repeated_once += pat_sums[max_pat_len]
    end
    # Part 2 (add the total sum, minus potential double counts).
    @repeated_mult += sum
  end
end

# Part 1
puts "Sum of numbers with sequence repeated twice: #{@repeated_once}"

# Part 2
puts "Sum of numbers with a sequence repeated multiple times: #{@repeated_mult}"
