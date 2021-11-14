# The challenge here was basically to analyze the given assembly code and
# refactor it. A general solution for any input is therefore quite hard.

b = 57 * 100 + 100000
c = b + 17000
h = 0

loop do
  d = 2
  #begin
  #  e = 2
  #  f = 1
  #  begin
  #    if d * e == b
  #      f = 0
  #    end
  #    e += 1
  #  end while e != b
  #  d += 1
  #end while d != b
  while d * d < b
    if b % d == 0
      f = 0
      break
    end
    d += 1
  end

  if f == 0
    h += 1
  end

  if b == c
    break
  end
  b += 17
end

puts h
