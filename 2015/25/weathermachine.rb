row = 3010; col = 3019
#row = 4; col = 3

code = 20151125
mul = 252533
mod = 33554393

((1..(row + col - 2)).to_a.sum + col - 1).times { code = (code * mul) % mod }
puts "Code at row #{row}, column #{col}: #{code}"
