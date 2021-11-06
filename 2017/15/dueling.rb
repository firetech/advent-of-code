val_A = 703; val_B = 516
#val_A = 65; val_B = 8921

fac_A = 16807; fac_B = 48271
mod = 2147483647
low16 = 0xFFFF

queue_A = []
queue_B = []

part1_matches = 0
tries = 0
cont_part1 = true
cont_part2_A = true
cont_part2_B = true
while cont_part1 or cont_part2_A or cont_part2_B
  if cont_part1 or cont_part2_A
    val_A = (val_A * fac_A) % mod
    if val_A % 4 == 0
      queue_A << val_A
      cont_part2_A = queue_A.length < 5_000_000
    end
  end
  if cont_part1 or cont_part2_B
    val_B = (val_B * fac_B) % mod
    if val_B % 8 == 0
      queue_B << val_B
      cont_part2_B = queue_B.length < 5_000_000
    end
  end
  if cont_part1 and (val_A & low16) ^ (val_B & low16) == 0
    part1_matches += 1
  end
  tries += 1
  cont_part1 = tries < 40_000_000
end

# Part 1
puts "#{part1_matches} matches (every value)"

# Part 2
part2_matches = 0
while not queue_A.empty? and not queue_B.empty?
  if (queue_A.shift & low16) ^ (queue_B.shift & low16) == 0
    part2_matches += 1
  end
end

puts "#{part2_matches} matches (only values divisible by 4(A) or 8(B))"
