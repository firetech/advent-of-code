require_relative '../../lib/aoc_api'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

# Classes for tree structure
class TreeDir
  @@sizes = {}

  attr_reader :name

  def initialize(name)
    @name = name
    @children = {}
  end

  def <<(child)
    @@sizes.delete(self)
    @children[child.name] = child
  end

  def [](child)
    @children[child]
  end

  def size
    unless @@sizes.has_key?(self)
      @@sizes[self] = @children.values.map(&:size).sum
    end
    return @@sizes[self]
  end

  def self.all_sizes
    return @@sizes.values.sort
  end
end

class TreeFile
  attr_reader :name, :size

  def initialize(name, size)
    @name = name
    @size = size.to_i
  end
end

# Build up tree from input
@tree = TreeDir.new('/')
pwd = [@tree]
last_cmd = nil
File.read(file).rstrip.split("\n").each do |line|
  if line =~ /\A\$ (.*)\z/
    cmd = Regexp.last_match(1)
    case cmd
    when /\Acd (.*)\z/
      dir = Regexp.last_match(1)
      case dir
      when '/'
        pwd = [@tree]
      when '..'
        pwd.pop
      else
        pwd << pwd.last[Regexp.last_match(1)]
        raise "Unknown directory 'dir'" if pwd.last.nil?
      end
    when 'ls'
      # Do nothing
    else
      raise "Unknown command: '#{cmd}'"
    end
    last_cmd = cmd
  elsif last_cmd == 'ls'
    case line
    when /\A(\d+) (.*)\z/
      # File
      pwd.last << TreeFile.new(Regexp.last_match(2), Regexp.last_match(1))
    when /\Adir (.*)\z/
      # Dir
      pwd.last << TreeDir.new(Regexp.last_match(1))
    else
      raise "Malformed ls output: '#{line}'"
    end
  else
    raise "Unexpected line: '#{line}'"
  end
end

# Precalculate all directory sizes.
total_size = @tree.size

# Part 1
sum = 0
TreeDir.all_sizes.each do |val|
  sum += val if val < 100000
end
puts "Sum of directory sizes < 100000: #{sum}"


# Part 2
TOTAL_SPACE  = 70000000
NEEDED_SPACE = 30000000

free = TOTAL_SPACE - total_size
min_remove = NEEDED_SPACE - free

TreeDir.all_sizes.each do |size|
  if size >= min_remove
    puts "Size of smallest directory that frees up enough space: #{size}"
    break
  end
end
