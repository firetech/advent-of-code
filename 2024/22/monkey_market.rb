require 'set'
require_relative '../../lib/aoc'
require_relative '../../lib/multicore'

file = ARGV[0] || AOC.input_file()
#file = 'example1'
#file = 'example2'

@numbers = File.read(file).rstrip.split("\n").map(&:to_i)
#@numbers = [123]

PRUNE = 0xffffff
def next_secret(n)
  n = (n ^ (n << 6)) & PRUNE     # (n ^ (n * 64)) % 16777216
  n = (n ^ (n >> 5)) & PRUNE     # (n ^ (n / 32)) % 16777216
  return (n ^ (n << 11)) & PRUNE # (n ^ (n * 2048)) % 16777216
end

stop = nil
max_threads = [16, @numbers.length].min
begin
  input, output, stop, nrunners = Multicore.run(-max_threads) do |worker_in, worker_out|
    sum2000 = 0
    totals = Hash.new(0)
    worker_in[].each do |num|
      d1 = d2 = d3 = d4 = nil
      seen = Set[]
      last = num % 10
      num = next_secret(num)
      1999.times do
        # Part 2
        price = num % 10
        d4 = d3
        d3 = d2
        d2 = d1
        d1 = last - price
        if d4
          key = ((d1 + 9) << 15) | ((d2 + 9) << 10) | ((d3 + 9) << 5) | (d4 + 9)
          totals[key] += price if seen.add?(key)
        end
        last = price
        num = next_secret(num)
      end

      # Part 1
      sum2000 += num
    end
    worker_out[[sum2000, totals]]
  end
  runner_slice = (@numbers.length / nrunners.to_f).ceil
  @numbers.each_slice(runner_slice) do |list|
    input << list
  end
  @sum2000 = 0 # Part 1
  @totals = {} # Part 2
  (@numbers.length / runner_slice.to_f).ceil.times do
    sum2000, totals = output.pop
    @sum2000 += sum2000 # Part 1
    @totals.merge!(totals) { |_, v1, v2| v1 + v2 } # Part 2
  end
ensure
  stop[]
end

# Part 1
puts "Sum of all 2000th secret numbers: #{@sum2000}"

# Part 2
puts "Maximum number of bananas: #{@totals.values.max}"
