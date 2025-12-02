require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@repeated_once = 0  # Part 1
@repeated_mult = 0  # Part 2
File.read(file).rstrip.split(",").each do |range|
  case range
  when /\A(\d+)-(\d+)\z/
    min = Regexp.last_match(1).to_i
    max = Regexp.last_match(2).to_i
    min.upto(max) do |n|
      @repeated_once += n if n.to_s =~ /\A(\d+)\1\z/  # Part 1
      @repeated_mult += n if n.to_s =~ /\A(\d+)\1+\z/  # Part 2
    end
  else
    raise "Malformed range: '#{range}'"
  end
end

# Part 1
puts "Sum of numbers with sequence repeated twice: #{@repeated_once}"

# Part 2
puts "Sum of numbers with a sequence repeated multiple times: #{@repeated_mult}"
