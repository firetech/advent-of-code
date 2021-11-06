file = 'input'
#file = 'example1'

@scanners = {}
File.read(file).strip.split("\n").each do |line|
  if line =~ /\A(\d+): (\d+)\z/
    depth = Regexp.last_match(1).to_i
    range = Regexp.last_match(2).to_i
    if @scanners.has_key?(depth)
      raise "Duplicate depth: #{depth}"
    end
    @scanners[depth] = range
  else
    raise "Malformed line: '#{line}'"
  end
end
@max_depth = @scanners.keys.max

# Part 1
depth = 0
severity = 0
@scanners.each do |depth, range|
  if depth % ((range - 1)*2) == 0
    severity += depth * range
  end
end
puts "Severity of starting immediately: #{severity}"

# Part 2
delay = 1
continue = true
while continue
  continue = false
  @scanners.each do |depth, range|
    if (depth + delay) % ((range - 1)*2) == 0
      continue = true
      delay += 1
      break
    end
  end
end
puts "Delay needed for safe passage: #{delay}"
