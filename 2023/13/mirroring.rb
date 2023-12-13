require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@patterns = File.read(file).rstrip.split("\n\n").map do |block|
  block.split("\n").map(&:chars)
end

@order = {}
def find_fold(lines)
  # Generate a somewhat optimal order of position checks
  order = @order[lines.count]
  if order.nil?
    middle = lines.count / 2
    order = [ middle ]
    min = middle - 1
    max = middle + 1
    while min >= 1 or max < lines.count
      order << min if min >= 1
      order << max if max < lines.count
      min -= 1
      max += 1
    end
    @order[lines.count] = order
  end
  order.each do |i|
    found = true
    before, after = lines[0...i], lines[i..-1]
    len = [after.length, before.length].min
    next if before.last(len) != after.first(len).reverse
    return i
  end
  return nil
end

sum = 0
@patterns.each do |pat|
  fold_y = find_fold(pat)
  if fold_y.nil?
    sum += find_fold(pat.transpose)
  else
    sum += 100 * fold_y
  end
end
puts "Fold position summary: #{sum}"
