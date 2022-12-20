file = ARGV[0] || 'input'
#file = 'example1'

class ListNum
  attr_reader :val
  attr_accessor :prev, :next

  def initialize(val, left = nil, right = nil)
    @val = val
    @prev = left || self
    @next = right || self
  end
end

@nodes1 = []  # Part 1
@nodes2 = []  # Part 2
File.read(file).rstrip.split("\n").each do |line|
  # Part 1
  node1 = ListNum.new(line.to_i, @nodes1.last, @nodes1.first)
  unless @nodes1.empty?
    @nodes1.last.next = node1
    @nodes1.first.prev = node1
  end
  @nodes1 << node1

  # Part 2
  node2 = ListNum.new(line.to_i * 811589153, @nodes2.last, @nodes2.first)
  unless @nodes2.empty?
    @nodes2.last.next = node2
    @nodes2.first.prev = node2
  end
  @nodes2 << node2
end

def mix(nodes)
  zero = nil
  nodes.each do |node|
    if node.val > 0
      moves = node.val % (nodes.length - 1)
      next if moves == 0
      n = node.next
      node.prev.next = n
      n.prev = node.prev
      (moves - 1).times { n = n.next }
      n.next.prev = node
      node.next = n.next
      n.next = node
      node.prev = n
    elsif node.val < 0
      moves = (-node.val) % (nodes.length - 1)
      next if moves == 0
      p = node.prev
      node.next.prev = p
      p.next = node.next
      (moves - 1).times { p = p.prev }
      p.prev.next = node
      node.prev = p.prev
      node.next = p
      p.prev = node
    else
      zero = node
    end
  end
  return zero
end

def grove_sum(zero)
  node = zero
  return 3.times.sum do
    1000.times { node = node.next }
    node.val
  end
end

# Part1
puts "Sum of grove coordinates: #{grove_sum(mix(@nodes1))}"

# Part 2
zero = nil
10.times do
  zero = mix(@nodes2)
end

puts "Sum of grove coordinates with decryption key: #{grove_sum(zero)}"
