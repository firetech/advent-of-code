require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

workflows, parts = File.read(file).rstrip.split("\n\n")

@workflows = {}
workflows.split("\n").each do |line|
  case line
  when /\A([a-z]+)\{(.+)\}\z/
    workflow = []
    @workflows[Regexp.last_match(1)] = workflow
    Regexp.last_match(2).split(',').each do |match|
      case match
      when /\A([xmas])([<>])(\d+):([a-z]+|[AR])\z/
        rating = Regexp.last_match(1)
        check = Regexp.last_match(2).to_sym
        value = Regexp.last_match(3).to_i
        goto = Regexp.last_match(4)
        workflow << [
          -> (part) { part[rating].send(check, value) },
          goto
        ]
      when /\A([a-z]+|[AR])\z/
        workflow << Regexp.last_match(1)
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
        part[Regexp.last_match(1)] = Regexp.last_match(2).to_i
      else
        raise "Malformed rating: '#{rating}'"
      end
    end
  else
    raise "Malformed part line: '#{line}'"
  end
end

@accepted = @parts.select do |part|
  workflow = 'in'
  until ['A', 'R'].include?(workflow)
    @workflows[workflow].each do |step|
      case step
      when String
        workflow = step
      when Array
        check, goto = step
        if check[part]
          workflow = goto
          break
        end
      else
        raise "Unexpected workflow step: #{step.inspect}"
      end
    end
  end
  workflow == 'A'
end

puts "Sum of accepted part ratings: #{@accepted.sum { |part| part.values.sum }}"
