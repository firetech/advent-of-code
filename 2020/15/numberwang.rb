input = [0,13,16,17,1,10,6]
#input = [0,3,6]

last_index = {}
next_num = nil
input.each_with_index do |n, i|
  if i == input.length - 1
    if last_index.has_key?(n)
      next_num = i - last_index[n]
    else
      next_num = 0
    end
  end
  last_index[n] = i
end
(input.length...30000000).each do |i|
  n = next_num
  if i == 2019 or i == 29999999
    puts "#{i+1}th number: #{n}"
  end
  next_num = i - (last_index[n] or i)
  last_index[n] = i
end
