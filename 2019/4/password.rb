input = 240920..789857

PART = 2

def pw_ok?(pw)
  pw_s = pw.to_s
  if not pw_s =~ /(.)\1/
    return false
  end
  if PART == 2
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

good_pw = input.select { |pw| pw_ok?(pw) }

puts "#{good_pw.length} good passwords found"
