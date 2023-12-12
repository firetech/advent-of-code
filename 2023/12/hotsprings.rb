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

def filter_possible(list, groups)
  return list.select do |pattern|
    group = 0
    in_group = 0
    possible = true
    done = true
    (pattern + [false]).each do |val|
      case val
      when nil
        # Can't know anything from this part on
        done = false
        break
      when true
        if group >= groups.length or in_group > groups[group]
          possible = false
          done = false
          break
        end
        in_group += 1
      when false
        next if in_group == 0
        if in_group == groups[group]
          in_group = 0
          group += 1
        else
          possible = false
          done = false
          break
        end
      end
    end
    if done and group < groups.length
      possible = false
    end
    possible
  end
end

sum = 0
@list.each do |pattern, groups|
  possible = [pattern]
  pattern.each_with_index do |val, i|
    next unless val.nil?
    new_possible = []
    possible.each do |p|
      p_false = p.clone
      p_false[i] = false
      new_possible << p_false
      p_true = p.clone
      p_true[i] = true
      new_possible << p_true
    end
    possible = filter_possible(new_possible, groups)
  end
  sum += possible.length
end
puts "Sum of possible arrangement counts: #{sum}"
