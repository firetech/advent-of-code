require_relative '../../lib/aoc_api'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

GENERATIONS = [ 20, 50_000_000_000 ]

def potstr_to_i(str)
  val = 0
  str.each_char.with_index do |c, i|
    if c == '#'
      val |= 1 << i
    end
  end
  return val
end

def pots_sum(pots, min)
  sum = 0
  i = 0
  while pots > 0
    sum += i + min if pots & 1 != 0
    i += 1
    pots >>= 1
  end
  return sum
end

@transforms = Hash.new(false)
File.read(file).strip.split("\n").each do |line|
  case line
  when /\Ainitial state: ([#.]+)\z/
    str = Regexp.last_match(1)
    @max_pot = str.length - 1
    @pots = potstr_to_i(str)
  when ''
    # Ignore
  when /\A([#.]{5}) => ([#.])\z/
    if Regexp.last_match(2) == '#'
      @transforms[potstr_to_i(Regexp.last_match(1))] = true
    end
  else
    raise "Malformed line: '#{line}'"
  end
end

raise "Space would explode with these transformations" if @transforms[0]

# Add 4 pots at each end to check all possible patterns at start and end.
pots = @pots << 4
min_pot = -4
max_pot = @max_pot + 4
mask = 0b11111
seen = Hash.new
i = 0
while i < GENERATIONS.max
  next_pots = 0
  (max_pot - min_pot + 1).times do |p|
    shift = p - 2
    if @transforms[(pots & (mask << shift)) >> shift]
      next_pots |= 1 << p
      if pots >> p == 0
        max_pot += 1
      end
    end
  end
  pots = next_pots
  # Shift cluster until the four lowest bits (and no more) are unused.
  while pots & 0b1111 != 0
    pots <<= 1
    min_pot -= 1
  end
  while pots & 0b11111 == 0
    pots >>= 1
    min_pot += 1
  end
  i+= 1

  if GENERATIONS.include?(i)
    puts "Sum after #{i} generations: #{pots_sum(pots, min_pot)}"
  end
  if seen.has_key?(pots)
    # Glider state (or equilibrium) reached. Further states can be extrapolated.
    break
  end
  seen[pots] = [min_pot, i]
end

if i < GENERATIONS.max
  seen_min, seen_i = seen[pots]
  min_diff = seen_min - min_pot
  i_diff = seen_i - i
  GENERATIONS.each do |g|
    next if g <= i
    g_min = min_pot + (min_diff * (g - i) / i_diff.to_f).to_i
    puts "Sum after #{g} generations: #{pots_sum(pots, g_min)}"
  end
end
