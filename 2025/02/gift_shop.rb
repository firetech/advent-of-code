require 'set'

require_relative '../../lib/aoc'
require_relative '../../lib/multicore'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@ranges = []
File.read(file).rstrip.split(",").each do |range|
  case range
  when /\A(\d+)-(\d+)\z/
    @ranges << [Regexp.last_match(1), Regexp.last_match(2)]
  else
    raise "Malformed range: '#{range}'"
  end
end

@repeated_once = 0  # Part 1
@repeated_mult = 0  # Part 2
stop = nil
begin
  max_threads = [8, @ranges.length].min
  input, output, stop = Multicore.run(-max_threads) do |worker_in, worker_out|
    loop do
      min, max = worker_in[]
      range = (min.to_i..max.to_i)

      rep_once = 0  # Part 1
      rep_mult = 0  # Part 2
      # Generate all the invalid numbers in range
      min.length.upto(max.length) do |num_digits|
        invalids_once = Set[]
        invalids_mult = Set[]
        1.upto(num_digits/2).each do |pat_len|
          reps, rest = num_digits.divmod(pat_len)
          next if rest != 0  # Must be an even split
          pat_start = 10**(pat_len - 1)  # e.g. pat_len=3 -> 100
          pat_end = pat_start *  10 - 1  # e.g. pat_len=3 -> 999
          (pat_start).upto(pat_end) do |pat|
            num = (pat.to_s * reps).to_i
            next unless range.include?(num)
            invalids_once << num if reps == 2
            invalids_mult << num
          end
        end
        rep_once += invalids_once.sum
        rep_mult += invalids_mult.sum
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
