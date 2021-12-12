require 'set'

file = 'input'
#file = 'example1'
#file = 'example2'

@nodes = {}

File.read(file).strip.split("\n").each do |line|
  case line
  when /\A([a-zA-Z]+)-([a-zA-Z]+)\z/
    a = Regexp.last_match(1)
    b = Regexp.last_match(2)
    @nodes[a] ||= []
    @nodes[b] ||= []
    @nodes[a] << b
    @nodes[b] << a
  else
    raise "Malformed line: '#{line}'"
  end
end

print "Traversing..."
queue = [['start', ['start'], nil]]
paths = []
i = 0
while not queue.empty?
  print '.' if (i += 1) % 10000 == 0

  pos, path, double = queue.shift
  @nodes[pos].each do |cave|
    cave_path = path + [cave]
    if cave == 'end'
      paths << [cave_path, double]
    else
      if path.include?(cave) and not cave =~ /\A[[:upper:]]+\z/
        if double.nil? and cave != 'start'
          queue << [cave, cave_path, cave]
        end
      else
        queue << [cave, cave_path, double]
      end
    end
  end
end
puts " Done."

# Part 1
puts "Possible paths: #{paths.map(&:last).count(nil)}"

# Part 2
puts "Possible paths with one small cave visited at most twice: #{paths.length}"
