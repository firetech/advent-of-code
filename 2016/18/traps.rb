require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
rows = ARGV.length > 1 ? ARGV[1..-1].map(&:to_i) : [40, 400000]

#file = 'example1'; rows = [3]
#file = 'example2'; rows = [10]

input = File.read(file).strip.chars.map { |c| c == '^' }

line = input
row = 1
safe_count = input.count(false)
rows.each do |size|
  while row < size
    line = [false, *line, false].each_cons(3).map do |left, center, right|
      ((left and not right) or (right and not left))
    end
    safe_count += line.count(false)
    row += 1
  end
  puts "Safe tiles in #{size} rows: #{safe_count}"
end
