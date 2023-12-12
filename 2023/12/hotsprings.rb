require_relative '../../lib/aoc'
require_relative '../../lib/multicore'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@cache = {}
def count_possibles(pattern, groups, clear_cache = true)
  @cache.clear if clear_cache

  if groups.empty?
    # We're done (or are we?)
    return (pattern.nil? or not pattern.include?('#')) ? 1 : 0
  end
  # Out of springs to check (but we still have groups left)
  return 0 if pattern.nil?

  g = groups.first
  # Group doesn't fit in remaining pattern
  return 0 if pattern.length < g

  cache_key = pattern.length << 8 | groups.length
  possible = @cache[cache_key]
  # Try consuming a group or moving to the next spring
  if possible.nil?
    possible = 0
    if not pattern[0,g].include?('.') and pattern[g] != '#'
      # Group fits, consume it (and a separator after)
      possible += count_possibles(pattern[g+1..-1], groups[1..-1], false)
    end
    if pattern[0] != '#'
      # Group is not enforced, move to next spring without consuming a group
      possible += count_possibles(pattern[1..-1], groups, false)
    end
    @cache[cache_key] = possible
  end
  return possible
end

sum1 = 0
sum2 = 0
File.read(file).rstrip.split("\n").each do |line|
  case line
  when /\A([.?#]+) ((?:\d+(?:,|\z))+)/
    pattern = Regexp.last_match(1)
    groups = Regexp.last_match(2).split(',').map(&:to_i)
  else
    raise "Malformed line: '#{line}'"
  end

  # Part 1
  sum1 += count_possibles(pattern, groups)

  # Part 2 (reusing the cache from part 1, since the ends are the same)
  sum2 += count_possibles(([pattern] * 5).join('?'), groups * 5, false)
end

# Part 1
puts "Sum of possible arrangement counts: #{sum1}"

# Part 2
puts "Sum of possible arrangement counts (unfolded): #{sum2}"
