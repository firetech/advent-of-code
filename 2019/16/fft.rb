input = File.read('input').strip
#input = '80871224585914546619083218645595'
#input = '19617804207202209144916044189917'
#input = '69317163492948606335995924319873'

@list = input.chars.map(&:to_i)

@patterns = {}
def get_pattern(index, length)
  if not @patterns.has_key?(index)
    pattern = []
    [0, 1, 0, -1].each do |elem|
      if pattern.length > length
        break
      end
      pattern += [elem] * (index + 1)
    end
    if pattern.length < (length + 1)
      pattern *= ((length + 1.0) / pattern.length).ceil
    end
    @patterns[length] ||= {}
    @patterns[length][index] = pattern[1..length]
  end
  return @patterns[length][index]
end

def fft(list)
  new_list = []
  (0...list.length).each do |index|
    pattern = get_pattern(index, list.length)
    sum = 0
    list.zip(pattern) do |digit, multiplier|
      sum += digit * multiplier
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
