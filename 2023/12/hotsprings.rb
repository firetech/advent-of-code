require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@list = []
File.read(file).rstrip.split("\n").each do |line|
  case line
  when /\A([.?#]+) ((?:\d+(?:,|\z))+)/
    @list << [
      Regexp.last_match(1).chars.map do |c|
        case c
        when '.'
          false
        when '?'
          nil
        when '#'
          true
        end
      end,
      Regexp.last_match(2).split(',').map(&:to_i)
    ]
  else
    raise "Malformed line: '#{line}'"
  end
end

@cache = {}
def count_possibles(pattern, groups, in_group = 0)
  cache_key = [pattern, groups, in_group].hash
  cache = @cache[cache_key]
  if cache.nil?
    cache = inner_count_possibles(pattern, groups, in_group)
    @cache[cache_key] = cache
  end
  return cache
end
def inner_count_possibles(pattern, groups, in_group = 0)
  # Base cases
  if pattern.empty?
    if in_group > 0
      return (groups.length == 1 and in_group == groups.first) ? 1 : 0
    else
      return groups.empty? ? 1 : 0
    end
  end

  # Current group is too long
  return 0 if in_group > 0 and (groups.empty? or in_group > groups.first)

  case pattern.first
  when false
    if in_group > 0
      if in_group != groups.first
        return 0
      end
      groups = groups[1..-1]
    end
    return count_possibles(pattern[1..-1], groups, 0)
  when true
    return count_possibles(pattern[1..-1], groups, in_group+1)
  when nil
    if groups.empty? or in_group == groups.first
      # No groups left, or current group is done, spring must be broken
      groups = groups[1..-1] || []
      return count_possibles(pattern[1..-1], groups, 0)
    end
    if in_group > 0
      # Current group isn't filled yet, spring must be operational
      return count_possibles(pattern[1..-1], groups, in_group+1)
    end
    # Group hasn't started, we'll have to try both alternatives
    return count_possibles(pattern[1..-1], groups, in_group+1) +
           count_possibles(pattern[1..-1], groups, in_group)
  end
end

# Part 1
sum = 0
@list.each do |pattern, groups|
  sum += count_possibles(pattern, groups)
end
puts "Sum of possible arrangement counts: #{sum}"

# Part 2
sum = 0
@list.each do |pattern, groups|
  sum += count_possibles(
    pattern + ([nil] + pattern) * 4,
    groups * 5
  )
end
puts "Sum of possible arrangement counts (unfolded): #{sum}"
