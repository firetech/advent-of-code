require 'set'

file = 'input'
#file = 'example1'

GENERATIONS = [ 20, 50_000_000_000 ]

@transforms = Hash.new(false)
@pots = Set[]
File.read(file).strip.split("\n").each do |line|
  case line
  when /\Ainitial state: ([#.]+)\z/
    Regexp.last_match(1).each_char.with_index do |c, i|
      @pots << i if c == '#'
    end
  when ''
    # Ignore
  when /\A([#.]{5}) => ([#.])\z/
    if Regexp.last_match(2) == '#'
      state = []
      Regexp.last_match(1).each_char.with_index do |c, i|
        state << i-2 if c == '#'
      end
      raise 'Space would explode' if state.empty?
      @transforms[state] = true
    end
  else
    raise "Malformed line: '#{line}'"
  end
end

pots = @pots
sum = pots.sum
diff = nil
repeats = 0
i = 0
# Loop until sum difference converges
begin
  last_diff = diff
  last_sum = sum

  next_pots = Set[]
  (pots.min-2).upto(pots.max+2) do |pot|
    state = []
    -2.upto(2) do |offset|
      state << offset if pots.include?(pot + offset)
    end
    if @transforms[state]
      next_pots << pot
    end
  end
  pots = next_pots
  sum = pots.sum

  i+= 1
  if GENERATIONS.include?(i)
    # Part 1
    puts "Sum after #{i} generations: #{sum}"
  end
  diff = sum - last_sum

  if diff == last_diff
    repeats += 1
  else
    repeats = 0
  end
end while repeats < 20

GENERATIONS.each do |g|
  next if g <= i
  puts "Sum after #{g} generations: #{sum + (g - i) * diff}"
end
