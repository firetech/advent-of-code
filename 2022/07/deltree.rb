file = ARGV[0] || 'input'
#file = 'example1'

# Build up tree
@pwd = []
@tree = {}
File.read(file).rstrip.split(/^\$ /)[1..-1].each do |step|
  cmd, output = step.split("\n", 2)
  case cmd
  when /\Acd (.*)\z/
    case Regexp.last_match(1)
    when '/'
      @pwd = []
    when '..'
      @pwd.pop
    else
      @pwd << Regexp.last_match(1)
    end
  when /\Als\z/
    tree = @tree
    @pwd.each do |path|
      tree = tree[path]
    end
    output.split("\n").each do |line|
      case line
      when /\A(\d+) (.*)\z/
        # File
        tree[Regexp.last_match(2)] = Regexp.last_match(1).to_i
      when /\Adir (.*)\z/
        # Dir
        tree[Regexp.last_match(1)] = {}
      else
        raise "Malformed line: '#{line}'"
      end
    end
  end
end

# Get size for each directory (recursively)
@dir_size = {}
def path_size(path = [])
  unless @dir_size.has_key?(path)
    tree = @tree
    path.each do |step|
      tree = tree[step]
    end
    if tree.is_a? Integer
      return tree
    else
      @dir_size[path] = tree.sum { |k, v| path_size(path + [k]) }
    end
  end
  return @dir_size[path]
end
path_size()


# Part 1
sum = 0
@dir_size.values.each do |val|
  sum += val if val < 100000
end
puts "Sum of directory sizes < 100000: #{sum}"


# Part 2
TOTAL = 70000000
NEEDED = 30000000

free = TOTAL - path_size()
min_remove = NEEDED - free

@dir_size.sort_by(&:last).each do |path, size|
  if size >= min_remove
    puts "Size of smallest directory that frees up enough space: #{size}"
    break
  end
end
