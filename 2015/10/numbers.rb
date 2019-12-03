input = 1113122113
#input = 1

#part 1
def numberwang(input, iterations)
  x = input.to_s
  iterations.times do
    x.gsub!(/(.)\1*/) do |rep|
      "#{rep.length}#{rep[0]}"
    end
  end
  return x
end

x = numberwang(input, 40)
puts "Length after 40 iterations: #{x.length}"

#part 2
x = numberwang(x, 10)
puts "Length after 50 iterations: #{x.length}"
