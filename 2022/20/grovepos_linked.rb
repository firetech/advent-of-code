require_relative '../../lib/aoc_api'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

class ListNum
  attr_accessor :val, :prev, :next

  def initialize(val, left = nil, right = nil)
    @val = val
    @prev = left || self
    @next = right || self
  end
end

@nodes = []
File.read(file).rstrip.split("\n").each do |line|
  node = ListNum.new(line.to_i, @nodes.last, @nodes.first)
  unless @nodes.empty?
    @nodes.last.next = node
    @nodes.first.prev = node
  end
  @nodes << node
end

def mixed_sum(count = 1)
  zero = nil
  pos_mod = @nodes.length - 1
  count.times do
    @nodes.each do |node|
      if node.val == 0
        zero = node
        next
      end
      moves = node.val % pos_mod # Never negative (in Ruby)
      next if moves == 0
      n = node.next
      node.prev.next = n
      node.next.prev = node.prev
      moves.times { n = n.next }
      n.prev.next = node
      node.prev = n.prev
      n.prev = node
      node.next = n
    end
  end
  node = zero
  return 3.times.sum do
    1000.times { node = node.next }
    node.val
  end
end

# Part1
puts "Sum of grove coordinates: #{mixed_sum}"

# Part 2
# Reset nodes and multiply values by decryption key
last = @nodes.last
@nodes.each do |node|
  node.prev = last
  last.next = node
  last = node
  node.val *= 811589153
end
puts "Sum of grove coordinates with decryption key: #{mixed_sum(10)}"
