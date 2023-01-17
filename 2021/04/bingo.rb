require 'set'
require_relative '../../lib/aoc_api'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

numbers_str, *board_strs = File.read(file).strip.split("\n\n")

@numbers = numbers_str.split(',').map(&:to_i)
@boards = board_strs.map do |board|
  board.split("\n").map { |line| line.strip.split(/\s+/).map(&:to_i) }
end

def check_board(board, drawn)
  (board + board.transpose).any? { |line| line.all? { |n| drawn.include?(n) } }
end

def print_score(board, drawn, last_number)
  puts board.flatten.select { |n| not drawn.include?(n) }.sum * last_number
end

boards = @boards
drawn = Set[]
winning_board = nil
@numbers.each do |n|
  drawn << n
  if drawn.length >= 5
    if winning_board.nil?
      winning_board = @boards.find { |board| check_board(board, drawn) }
      unless winning_board.nil?
        print "Score of first winning board: "
        print_score(winning_board, drawn, n)
      end
    end
    last_boards = boards
    boards = boards.reject { |board| check_board(board, drawn) }
    if boards.empty?
      raise "Multiple last winners" if last_boards.length > 1
      print "Score of last winning board: "
      print_score(last_boards.first, drawn, n)
      break
    end
  end
end

