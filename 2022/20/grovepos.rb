require_relative '../../lib/aoc_api'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@numbers = File.read(file).rstrip.split("\n").map(&:to_i)

def mixed_sum(values, mix_count = 1)
  mix_with_index = values.each_with_index.to_a
  pos_mod = values.length - 1
  mix_count.times do
    values.each_index do |i|
      curr_i = mix_with_index.index { |_, orig_i| orig_i == i }
      item = mix_with_index.delete_at(curr_i)
      new_i = (curr_i + item.first) % pos_mod
      mix_with_index.insert(new_i, item)
    end
  end
  i = mix_with_index.index { |val, _| val == 0 }
  return 3.times.sum { mix_with_index[(i += 1000) % values.length].first }
end

# Part 1
puts "Sum of grove coordinates: #{mixed_sum(@numbers)}"

# Part 2
key_nums = @numbers.map { |n| n * 811589153 }
puts "Sum of grove coordinates with decryption key: #{mixed_sum(key_nums, 10)}"
