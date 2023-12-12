require_relative '../../lib/aoc'
require_relative '../../lib/multicore'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

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

  # Check first character and recurse to the next
  remaining = pattern[1..-1]
  case pattern[0]
  when '.'
    if in_group > 0
      # End current group, stop if it's the wrong length
      return 0 if in_group != groups.first
      groups = groups[1..-1]
    end
    return count_possibles(remaining, groups, 0)
  when '#'
    # Continue (or start) current group
    return count_possibles(remaining, groups, in_group+1)
  when '?'
    if groups.empty? or in_group == groups.first
      # No groups left, or current group is done, spring must be broken
      return count_possibles(remaining, groups[1..-1] || [], 0)
    elsif in_group > 0
      # Current group isn't done yet, spring must be operational
      return count_possibles(remaining, groups, in_group+1)
    end
    # Group hasn't started, we'll have to try both starting it and waiting
    return count_possibles(remaining, groups, in_group+1) +
           count_possibles(remaining, groups, in_group)
  else
    raise "Unexpected state: #{pattern[0]}"
  end
end

input, output, stop = Multicore.run do |worker_in, worker_out|
  until (line = worker_in[]).nil?
    case line
    when /\A([.?#]+) ((?:\d+(?:,|\z))+)/
      pattern = Regexp.last_match(1)
      groups = Regexp.last_match(2).split(',').map(&:to_i)
    else
      raise "Malformed line: '#{line}'"
    end

    worker_out[[0, count_possibles(pattern, groups)]]
    worker_out[[1, count_possibles(([pattern] * 5).join('?'), groups * 5)]]
  end
end
lines = 0
File.read(file).rstrip.split("\n").each do |line|
  input << line
  lines += 1
end
input.close
sum = [0, 0]
(lines * 2).times do
  part, possibles = output.pop
  sum[part] += possibles
end

# Part 1
puts "Sum of possible arrangement counts: #{sum[0]}"

# Part 2
puts "Sum of possible arrangement counts (unfolded): #{sum[1]}"
