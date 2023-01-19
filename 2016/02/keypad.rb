require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

input = File.read(file).strip.split("\n").map(&:chars)

# Part 1
code = []
row, col = 1, 1 # 5
input.each do |line|
  line.each do |dir|
    new_row, new_col = row, col
    case dir
    when 'U'
      new_row -= 1
    when 'D'
      new_row += 1
    when 'L'
      new_col -= 1
    when 'R'
      new_col += 1
    else
      raise "Where is '#{dir}'?"
    end
    if (0..2).include?(new_row) and (0..2).include?(new_col)
      row, col = new_row, new_col
    end
  end
  code << (row * 3 + col) + 1
end
puts "Code (square keypad): #{code.join}"

# Part 2
code = []
row, col = 3, 0 # 5
keypad = [
  [nil, nil,   1, nil, nil],
  [nil,   2,   3,   4, nil],
  [  5,   6,   7,   8,   9],
  [nil, 'A', 'B', 'C', nil],
  [nil, nil, 'D', nil, nil]
]
input.each do |line|
  line.each do |dir|
    new_row, new_col = row, col
    case dir
    when 'U'
      new_row -= 1
    when 'D'
      new_row += 1
    when 'L'
      new_col -= 1
    when 'R'
      new_col += 1
    else
      raise "Where is '#{dir}'?"
    end
    if (0..4).include?(new_row) and (0..4).include?(new_col) and not keypad[new_row][new_col].nil?
      row, col = new_row, new_col
    end
  end
  code << keypad[row][col]
end
puts "Code (diamond keypad): #{code.join}"
