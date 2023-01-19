require_relative '../../lib/aoc'

input = File.read(ARGV[0] || AOC.input_file()).strip.split("\n")
#input = File.read('example1').strip.split("\n")

seats = input.map do |line|
  row_min = 0
  row_max = 127
  column_min = 0
  column_max = 7
  line.each_char do |char|
    case char
    when 'F'
      row_max -= ((row_max - row_min)/2.0).ceil
    when 'B'
      row_min += ((row_max - row_min)/2.0).ceil
    when 'L'
      column_max -= ((column_max - column_min)/2.0).ceil
    when 'R'
      column_min += ((column_max - column_min)/2.0).ceil
    end
  end
  if row_min != row_min or column_min != column_max
    raise 'No consensus.'
  end
  [ row_min, column_min ]
end
seat_ids = seats.map { |row, column| row * 8 + column }

#part 1
max_id = seat_ids.max
puts "Highest seat ID: #{max_id}"

#part 2
gaps = (seat_ids.min..seat_ids.max).to_a - seat_ids
if gaps.length > 1
  raise "More than one empty seat"
end
puts "Your seat ID: #{gaps.first}"


