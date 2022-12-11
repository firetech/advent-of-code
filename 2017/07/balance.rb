input = File.read('input').strip
#input = File.read('example1').strip

@stack = {}

class Program
  attr_reader :name, :children
  attr_accessor :weight, :parent

  def initialize(name)
    @name = name
    @weight = nil
    @parent = nil
    @children = []
  end

  def <<(child)
    @children << child
  end

  def total_weight
    if not defined?(@total_weight)
      @total_weight = @weight + @children.sum { |child| child.total_weight }
    end
    @total_weight
  end
end

def get_program(name)
  if not @stack.include?(name)
    @stack[name] = Program.new(name)
  end
  @stack[name]
end

# Part 1
input.split("\n").each do |line|
  if line =~ /\A(\w+) \((\d+)\)(?: -> ((?:\w+(?:, )?)+))?\z/
    _, name, weight, children = Regexp.last_match.to_a
    program = get_program(name)
    program.weight = weight.to_i
    if not children.nil?
      children.split(', ').each do |child_name|
        child = get_program(child_name)
        child.parent = program
        program << child
      end
    end
  else
    raise "Malformed line: '#{line}'"
  end
end

@base = @stack.values.select { |p| p.parent.nil? }
if @base.length > 1
  raise "More than one base of the tree?!"
end
@base = @base.first

puts "Name of bottom program: #{@base.name}"

# Part 2
outlier = @base

while not outlier.children.empty?
  weights = outlier.children.map(&:total_weight)
  outlier_weights = weights.uniq.select { |w| weights.count(w) == 1 }
  if outlier_weights.empty?
    break
  elsif outlier_weights.length > 1
    raise "More than one outlier?!"
  end
  outlier = outlier.children[weights.index(outlier_weights.first)]
end

weights = outlier.parent.children.map(&:total_weight)
correct_weights = weights.uniq.select { |w| weights.count(w) > 1 }
if correct_weights.length != 1
  raise "No correct weight found for outlier"
end
outlier.weight += correct_weights.first - outlier.total_weight

puts "#{outlier.name}'s weight should be #{outlier.weight}"
