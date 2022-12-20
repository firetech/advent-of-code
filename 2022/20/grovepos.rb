file = ARGV[0] || 'input'
#file = 'example1'

@numbers = File.read(file).rstrip.split("\n").map(&:to_i)
INDEXES = [1000, 2000, 3000]

# Part 1
with_index = @numbers.each_with_index.to_a
0.upto(@numbers.length - 1) do |i|
  ci = with_index.index { |_, oi| oi == i }
  curr = with_index[ci]
  with_index.delete_at(ci)
  ni = (ci + curr.first) % (@numbers.length - 1)
  with_index.insert(ni, curr)
end

zero = with_index.index { |val, _| val == 0 }
sum = INDEXES.sum { |i| with_index[(zero + i) % @numbers.length].first }
puts "Sum of grove coordinates: #{sum}"

# Part 2
KEY = 811589153

with_index = @numbers.map.with_index { |val, i| [val * KEY, i] }
10.times do
  0.upto(@numbers.length - 1) do |i|
    ci = with_index.index { |_, oi| oi == i }
    curr = with_index[ci]
    with_index.delete_at(ci)
    ni = (ci + curr.first) % (@numbers.length - 1)
    with_index.insert(ni, curr)
  end
end

zero = with_index.index { |val, _| val == 0 }
sum = INDEXES.sum { |i| with_index[(zero + i) % @numbers.length].first }
puts "Sum of grove coordinates with decryption key: #{sum}"
