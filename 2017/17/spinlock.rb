input = 335; part2_max = 50_000_000
#input = 3; part2_max = 9

# Part 1
class Node
  attr_reader :value, :next

  def initialize(value)
    @value = value
    @next = self
  end

  def insert_after(node)
    self.next = node.next
    node.next = self
  end

  protected
  attr_writer :next
end

node = Node.new(0)
1.upto(2017) do |i|
  new_node = Node.new(i)
  input.times { node = node.next }
  new_node.insert_after(node)
  node = new_node
end

puts "Value after 2017 following its insertion: #{node.next.value}"

# Part 2
index = 1
num_after = 1
length = 2
2.upto(part2_max) do |i|
  index = ((index + input) % length) + 1
  length += 1
  if index == 1
    num_after = i
  end
end

puts "Value after 0 following insertion of #{part2_max}: #{num_after}"
