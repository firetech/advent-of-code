require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

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
File.read(file).rstrip.split("\n").each do |line|
  case line
  when /\A\d+\z/
    @batteries = line.to_i.digits.reverse
    @sum2 += get_max(@batteries, 2)  # Part 1
    @sum12 += get_max(@batteries, 12)  # Part 2
  else
    raise "Malformed line: '#{line}'"
  end
end

# Part 1
puts "Max joltage with 2 batteries per bank: #{@sum2}"

# Part 2
puts "Max joltage with 12 batteries per bank: #{@sum12}"
