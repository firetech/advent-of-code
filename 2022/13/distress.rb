file = ARGV[0] || 'input'
#file = 'example1'

@pairs = File.read(file).rstrip.split("\n\n").map do |pair|
  pair.split("\n").map { |line| eval(line) }
end

def compare(left, right)
  l_arr = left.is_a?(Array)
  r_arr = right.is_a?(Array)
  if not l_arr and not r_arr
    return left <=> right
  elsif l_arr and not r_arr
    return compare(left, [right])
  elsif not l_arr and r_arr
    return compare([left], right)
  else
    left.zip(right) do|l, r|
      return 1 if r.nil?
      cmp = compare(l, r)
      return cmp if cmp != 0
    end
    return left.length <=> right.length
  end
  return 0
end

# Part 1
indices = []
@pairs.each_with_index do |(left, right), i|
  cmp = compare(left, right)
  raise 'Equal?!' if cmp == 0
  indices << i + 1 if cmp < 0
end
puts "Sum of pair indices in right order: #{indices.sum}"

# Part 2
dividers = [ [[2]], [[6]] ]
@list = @pairs.flatten(1) + dividers
@list.sort! { |a, b| compare(a, b) }
puts "Decoder key: #{dividers.map{ |x| @list.index(x) + 1 }.inject(:*)}"
