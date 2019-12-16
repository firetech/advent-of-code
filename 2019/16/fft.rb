input = File.read('input').strip
#input = '80871224585914546619083218645595'
#input = '19617804207202209144916044189917'
#input = '69317163492948606335995924319873'

@list = input.chars.map(&:to_i)

# part 1
def fft(list)
  # Generate list of partial sums
  part_sums = [0]
  sum = 0
  list.each do |digit|
    sum += digit
    part_sums << sum
  end

  length = list.length
  new_list = []
  (1..length).each do |i|
    sum = 0
    # Add sums matching the 1 part
    ((i - 1)..length).step(4 * i) do |sum_start|
      sum_end = sum_start + i
      sum += part_sums[[sum_end, length].min] - part_sums[sum_start]
    end
    # Remove sums matching the -1 part
    ((3 * i - 1)..length).step(4 * i) do |diff_start|
      diff_end = diff_start + i
      sum -= part_sums[[diff_end, length].min] - part_sums[diff_start]
    end
    new_list << sum.abs % 10
  end
  return new_list
end

list = @list
100.times do
  list = fft(list)
end
puts "First eight digits: #{list[0...8].join}"
