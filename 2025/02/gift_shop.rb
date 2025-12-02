require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@repeated_once = 0  # Part 1
@repeated_mult = 0  # Part 2
File.read(file).rstrip.split(",").each do |range|
  case range
  when /\A(\d+)-(\d+)\z/
    Regexp.last_match(1).to_i.upto(Regexp.last_match(2).to_i) do |n|
      if n.to_s =~ /\A(\d+)(\1+)\z/
        if Regexp.last_match(1).length == Regexp.last_match(2).length
          @repeated_once += n  # Part 1
        end
        @repeated_mult += n  # Part 2
      end
    end
  else
    raise "Malformed range: '#{range}'"
  end
end

# Part 1
puts "Sum of numbers with sequence repeated twice: #{@repeated_once}"

# Part 2
puts "Sum of numbers with a sequence repeated multiple times: #{@repeated_mult}"
