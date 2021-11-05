input = File.read('input').strip
#input = '1122'
#input = '1111'
#input = '1234'
#input = '91212129'
#input = '1212'
#input = '1221'
#input = '123425'
#input = '123123'
#input = '12131514'

chars = input.chars

sum = {
  1 => 0,             # Part 1
  chars.length/2 => 0 # Part 2
}
chars.each_with_index do |c, i|
  sum.each_key do |offset|
    if c == chars[(i + offset) % chars.length]
      sum[offset] += c.to_i
    end
  end
end

sum.each do |offset, value|
  puts "CAPTCHA answer with offset #{offset}: #{value}"
end
