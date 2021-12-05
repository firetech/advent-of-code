file = 'input'
#file = 'example1'

@lines = File.read(file).strip.split("\n").map do |line|
  case line
  when /\A(\d+),(\d+) -> (\d+),(\d+)\z/
    Regexp.last_match.to_a[1..-1].map(&:to_i)
  else
    raise "Malformed line: '#{line}'"
  end
end

@grid1 = Hash.new(0) # Part 1
@grid2 = Hash.new(0) # Part 2
@lines.each do |x1, y1, x2, y2|
  if x1 == x2 or y1 == y2
    x1, x2 = x2, x1 if x1 > x2
    y1, y2 = y2, y1 if y1 > y2
    y1.upto(y2) do |y|
      x1.upto(x2) do |x|
        @grid1[[x, y]] += 1
        @grid2[[x, y]] += 1
      end
    end
  else
    steps = (x2 - x1).abs
    raise "Line is not at 90 or 45 degrees" if (y2 - y1).abs != steps
    x_sign = (x2 - x1) > 0 ? 1 : -1
    y_sign = (y2 - y1) > 0 ? 1 : -1
    0.upto(steps) do |delta|
      @grid2[[x1 + x_sign*delta, y1 + y_sign*delta]] += 1
    end
  end
end

# Part 1
puts "Overlapping points (90° lines only): #{@grid1.values.count { |v| v > 1 }}"

# Part 2
puts "Overlapping points (all lines): #{@grid2.values.count { |v| v > 1 }}"
