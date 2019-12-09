input = 'ckczppom'

#part 1
require 'digest/md5'

i = 1
loop do
  hash = Digest::MD5.hexdigest("#{input}#{i}")
  if hash =~ /^00000/
    break
  end
  i += 1
end

puts "Five zeroes value: #{i}"

#part 2
loop do
  hash = Digest::MD5.hexdigest("#{input}#{i}")
  if hash =~ /^000000/
    break
  end
  i += 1
end

puts "Six zeroes value: #{i}"
