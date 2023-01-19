require_relative '../../lib/aoc'

min, max = File.read(ARGV[0] || AOC.input_file()).strip.split('-').map(&:to_i)
range = min..max

def pw_ok?(pw, check_pair = false)
  pw_s = pw.to_s
  if not pw_s =~ /(.)\1/
    return false
  end
  if check_pair
    # This can be done cleaner with chunk or slice_when, but that is ~2-3 times slower
    has_no_pair = true
    pw_s.scan(/((.)\2+)/) do |match|
      if match[0].length == 2
        has_no_pair = false
        break
      end
    end
    if has_no_pair
      return false
    end
  end
  pw_s.each_char.each_cons(2) do |a,b|
    if b < a
      return false
    end
  end
  return true
end

# Part 1
good_pw = range.select { |pw| pw_ok?(pw) }
puts "#{good_pw.length} good passwords found"

# Part 2
good_pw2 = range.select { |pw| pw_ok?(pw, true) }
puts "#{good_pw2.length} good passwords with actual pairs found"
