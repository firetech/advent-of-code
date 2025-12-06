require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@columns = []
curr_col = nil
add_curr = ->() do
  op = curr_col.pop.join.strip.to_sym
  @columns << [curr_col, op]
  curr_col = nil
end
File.read(file).split("\n").map(&:chars).transpose.each do |col|
  if col.all?(" ")
    add_curr[]
  elsif curr_col.nil?
    curr_col = col.map { |r| [r] }
  else
    curr_col.zip(col) do |curr, new|
      curr << new
    end
  end
end
add_curr[]

# Part 1
sum1 = @columns.sum do |numbers, op|
  numbers.map(&:join).map(&:to_i).inject(&op)
end

puts "Sum of problems: #{sum1}"

# Part 2
sum2 = @columns.sum do |numbers, op|
  numbers.transpose.map(&:join).map(&:to_i).inject(&op)
end

puts "Sum of problems (right-to-left columns): #{sum2}"
