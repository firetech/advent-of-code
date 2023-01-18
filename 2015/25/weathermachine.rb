require_relative '../../lib/aoc_api'

pos = nil
#pos = [4, 3]

if pos.nil?
  File.read(ARGV[0] || AOC.input_file()).rstrip.split("\n").each do |line|
    case line
    when /Enter the code at row (\d+), column (\d+)\.\z/
      pos = [
        Regexp.last_match(1).to_i,
        Regexp.last_match(2).to_i
      ]
    else
      raise "Malformed line: '#{line}'"
    end
  end
end

row, col = pos

code = 20151125
mul = 252533
mod = 33554393

((1..(row + col - 2)).to_a.sum + col - 1).times { code = (code * mul) % mod }
puts "Code at row #{row}, column #{col}: #{code}"
