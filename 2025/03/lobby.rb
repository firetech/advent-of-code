require_relative '../../lib/aoc'
require_relative '../../lib/multicore'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@banks = []
File.read(file).rstrip.split("\n").each do |line|
  case line
  when /\A\d+\z/
    @banks << line.to_i
  else
    raise "Malformed line: '#{line}'"
  end
end

def get_max(bank, count)
  cache = {}
  find_max = ->(count_left, index) do
    cache_key = [count_left, index].hash
    max = cache[cache_key]
    if max.nil?
      if index < 0 or count_left < 1
        max = 0
      else
        next_index = index - 1
        max = [
          find_max[count_left - 1, next_index] * 10 + bank[index],
          find_max[count_left, next_index],
        ].max
      end
      cache[cache_key] = max
    end
    return max
  end

  return find_max[count, bank.length - 1]
end

@sum2 = 0  # Part 1
@sum12 = 0  # Part 2
stop = nil
begin
  input, output, stop, nrunners = Multicore.run(-8) do |worker_in, worker_out|
    sum2 = 0  # Part 1
    sum12 = 0  # Part 2
    loop do
      bank = worker_in[]
      break if bank == :done
      batteries = bank.digits.reverse
      sum2 += get_max(batteries, 2)  # Part 1
      sum12 += get_max(batteries, 12)  # Part 2
    end
    worker_out[[sum2, sum12]]
  end
  @banks.each { |bank| input << bank }
  nrunners.times do
    input << :done
    sum2, sum12 = output.pop
    @sum2 += sum2  # Part 1
    @sum12 += sum12  # Part 2
  end
ensure
  stop[] unless stop.nil?
end

# Part 1
puts "Max joltage with 2 batteries per bank: #{@sum2}"

# Part 2
puts "Max joltage with 12 batteries per bank: #{@sum12}"
