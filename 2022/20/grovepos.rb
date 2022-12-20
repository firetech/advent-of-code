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

@nodes = []
File.read(file).rstrip.split("\n").each do |line|
  node = ListNum.new(line.to_i, @nodes.last, @nodes.first)
  unless @nodes.empty?
    @nodes.last.next = node
    @nodes.first.prev = node
  end
  @nodes << node
end

@zero = nil
@nodes.each do |node|
  if node.val > 0
    (node.val).times do
      n = node.next
      node.prev.next = n
      n.prev = node.prev
      n.next.prev = node
      node.next = n.next
      n.next = node
      node.prev = n
    end
  elsif node.val < 0
    (-node.val).times do
      p = node.prev
      node.next.prev = p
      p.next = node.next
      p.prev.next = node
      node.prev = p.prev
      node.next = p
      p.prev = node
    end
  else
    @zero = node
  end
end

sum = 0
node = @zero
3.times do
  1000.times { node = node.next }
  sum += node.val
end

pp sum

