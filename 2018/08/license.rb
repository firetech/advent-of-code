file = 'input'
#file = 'example1'

@input = File.read(file).strip.scan(/\d+/).map(&:to_i)

class Node
  def self.parse(input, input_offset = 0)
    offset = input_offset
    num_children, num_meta = input[offset, 2]
    offset += 2
    children = []
    num_children.times do
      child, offset = parse(input, offset)
      children << child
    end
    meta = input[offset, num_meta]
    offset += num_meta
    node = new(children, meta)
    if input_offset > 0
      return node, offset
    else
      return node
    end
  end

  attr_reader :children, :meta

  private
  def initialize(children, meta)
    @children = children
    @meta = meta
  end

  public
  def value
    if @value.nil?
      if @children.empty?
        @value = meta.sum
      else
        meta_value = meta.map do |val|
          node = @children[val - 1]
          if node.nil?
            0
          else
            node.value
          end
        end
        @value = meta_value.sum
      end
    end
    return @value
  end
end

@tree = Node.parse(@input)

# Part 1
all_meta = []
queue = [@tree]
until queue.empty?
  node = queue.shift
  all_meta += node.meta
  queue += node.children
end

puts "Sum of all metadata: #{all_meta.sum}"

# Part 2
puts "Root node value: #{@tree.value}"
