file = 'input'
#file = 'example1'
#file = 'example2'

@nodes = {}

File.read(file).strip.split("\n").each do |line|
  case line
  when /\A([a-z]+|[A-Z]+)-([a-z]+|[A-Z]+)\z/
    a = Regexp.last_match(1)
    b = Regexp.last_match(2)
    @nodes[a] ||= []
    @nodes[b] ||= []
    @nodes[a] << b unless b == 'start'
    @nodes[b] << a unless a == 'start'
  else
    raise "Malformed line: '#{line}'"
  end
end

print "Traversing..."
stack = [['start', ['start'], nil]]
i = 0
paths = 0 # Part 1
double_paths = 0 # Part 2
while not stack.empty?
  pos, visited, double = stack.pop
  @nodes[pos].each do |cave|
    if cave == 'end'
      paths += 1 if double.nil?
      double_paths += 1
    else
      cave_double = double
      cave_visited = visited
      unless cave =~ /\A[A-Z]+\z/
        if visited.include?(cave)
          next unless double.nil?
          cave_double = cave
        else
          cave_visited += [cave]
        end
      end
      stack << [cave, cave_visited, cave_double]
    end
  end
end
puts " Done."
puts

# Part 1
puts "Possible paths: #{paths}"

# Part 2
puts "Possible paths with one small cave visited at most twice: #{double_paths}"
