require_relative '../../lib/aoc'
require_relative '../../lib/multicore'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@ranges = []
File.read(file).rstrip.split(",").each do |range|
  case range
  when /\A(\d+)-(\d+)\z/
    @ranges << [Regexp.last_match(1).to_i, Regexp.last_match(2).to_i]
  else
    raise "Malformed range: '#{range}'"
  end
end

@repeated_once = 0  # Part 1
@repeated_mult = 0  # Part 2
stop = nil
begin
  max_threads = [16, @ranges.length].min
  input, output, stop = Multicore.run(-max_threads) do |worker_in, worker_out|
    loop do
      min, max = worker_in[]
      rep_once = 0  # Part 1
      rep_mult = 0  # Part 2
      min.upto(max) do |n|
        if n.to_s =~ /\A(\d+)(\1+)\z/
          if Regexp.last_match(1).length == Regexp.last_match(2).length
            rep_once += n  # Part 1
          end
          rep_mult += n  # Part 2
        end
      end
      worker_out[[rep_once, rep_mult]]
    end
  end
  @ranges.each { |range| input << range }
  @ranges.length.times do
    rep_once, rep_mult = output.pop
    @repeated_once += rep_once
    @repeated_mult += rep_mult
  end
ensure
  stop[] unless stop.nil?
end

# Part 1
puts "Sum of numbers with sequence repeated twice: #{@repeated_once}"

# Part 2
puts "Sum of numbers with a sequence repeated multiple times: #{@repeated_mult}"
