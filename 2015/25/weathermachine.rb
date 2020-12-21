row = 3010; col = 3019
#row = 4; col = 3

code = 20151125
mul = 252533
mod = 33554393

((1..(row + col - 2)).to_a.inject(0) { |sum, x| sum + x } + col - 1).times do
  code = (code * mul) % mod
end
puts "Code at row #{row}, column #{col}: #{code}"
