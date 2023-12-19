require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

workflows, parts = File.read(file).rstrip.split("\n\n")

@workflows = {}
workflows.split("\n").each do |line|
  case line
  when /\A([a-z]+)\{(.+)\}\z/
    workflow = []
    @workflows[Regexp.last_match(1).to_sym] = workflow
    Regexp.last_match(2).split(',').each do |match|
      case match
      when /\A([xmas])([<>])(\d+):([a-z]+|[AR])\z/
        workflow << [
          rating = Regexp.last_match(1).to_sym,
          check = Regexp.last_match(2).to_sym,
          value = Regexp.last_match(3).to_i,
          goto = Regexp.last_match(4).to_sym,
        ]
      when /\A([a-z]+|[AR])\z/
        workflow << Regexp.last_match(1).to_sym
      end
    end
  else
    raise "Malformed workflow line: '#{line}'"
  end
end

@parts = []
parts.split("\n").each do |line|
  case line
  when /\A\{([xmas=\d,]+)\}\z/
    part = {}
    @parts << part
    Regexp.last_match(1).split(',').each do |rating|
      case rating
      when /\A([xmas])=(\d+)\z/
        part[Regexp.last_match(1).to_sym] = Regexp.last_match(2).to_i
      else
        raise "Malformed rating: '#{rating}'"
      end
    end
  else
    raise "Malformed part line: '#{line}'"
  end
end

# Part 1
accepted = @parts.select do |part|
  workflow = :in
  until [:A, :R].include?(workflow)
    @workflows[workflow].each do |step|
      case step
      when Symbol
        workflow = step
      when Array
        rating, check, value, goto = step
        if part[rating].send(check, value)
          workflow = goto
          break
        end
      else
        raise "Unexpected workflow step: #{step.inspect}"
      end
    end
  end
  workflow == :A
end

puts "Sum of accepted part ratings: #{@accepted.sum { |part| part.values.sum }}"


# Part 2
def num_accepted(workflow = :in, ranges = { x: 1..4000, m: 1..4000, a: 1..4000, s: 1..4000 })
  case workflow
  when :R
    return 0
  when :A
    return ranges.values.map(&:size).inject(&:*)
  end

  total = 0
  @workflows[workflow].each do |step|
    case step
    when Symbol
      total += num_accepted(step, ranges)
    when Array
      rating, check, value, goto = step
      curr = ranges[rating]
      next unless curr.include?(value) # We're out of range for this
      new_ranges = ranges.clone
      # Split range into what's matching this check and what isn't (for going to the next step)
      case check
      when :<
        new_ranges[rating] = curr.min..(value - 1) # Matching check
        ranges[rating] = value..curr.max # Not matching check
      when :>
        new_ranges[rating] = (value + 1)..curr.max # Matching check
        ranges[rating] = curr.min..value # Not matching check
      end
      total += num_accepted(goto, new_ranges)
    else
      raise "Unexpected workflow step: #{step.inspect}"
    end
  end
  return total
end

puts "Distinct rating combinations accepted: #{num_accepted}"
