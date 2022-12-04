file = ARGV[0] || 'input'
#file = 'example1'

@enclosed = 0 # Part 1
@overlap = 0 # Part 2
File.read(file).strip.split("\n").each do |line|
  case line
  when /\A(\d+)-(\d+),(\d+)-(\d+)\z/
    pair = [
      Regexp.last_match(1).to_i..Regexp.last_match(2).to_i,
      Regexp.last_match(3).to_i..Regexp.last_match(4).to_i
    ]

    # Part 1
    if (pair.first.include?(pair.last.min) and
        pair.first.include?(pair.last.max)) or
       (pair.last.include?(pair.first.min) and
        pair.last.include?(pair.first.max))
      @enclosed += 1
    end

    # Part 2
    if pair.first.include?(pair.last.min) or
       pair.first.include?(pair.last.max) or
       pair.last.include?(pair.first.min) or
       pair.last.include?(pair.first.max)
      @overlap += 1
    end
  else
    raise "Malformed line: '#{line}'"
  end
end

# Part 1
puts "Pairs where one range fully contain the other: #{@enclosed}"

# Part 2
puts "Pairs that overlap: #{@overlap}"

