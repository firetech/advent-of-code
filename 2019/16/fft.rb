input = File.read('input').strip
#input = '80871224585914546619083218645595'
#input = '19617804207202209144916044189917'
#input = '69317163492948606335995924319873'
#input = '03036732577212944063491565474664'
#input = '02935109699940807407585447034323'
#input = '03081770884921959731165446850517'

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


# part 2
offset = @list[0...7].join.to_i
raise "Offset has to end up in latter half, this won't work. :(" if offset < @list.length * 5000

begin
  require 'numo/narray'

  puts 'Running with Numo/NArray :)'

  list = Numo::UInt32[*@list].tile(10000)[offset..-1].reverse

  100.times do |i|
    list = list.cumsum % 10
  end

  message = list.reverse[0...8].to_a.join

rescue LoadError
  puts 'Running without Numo/NArray :('

  @real_list = @list * 10000
  list = @real_list[offset..-1].reverse
  100.times do |i|
    sum = 0
    new_list = []
    list.each do |digit|
      sum += digit
      new_list << sum.abs % 10
    end
    list = new_list
  end

  message = list.reverse[0...8].join
end

puts "Message: #{message}"
