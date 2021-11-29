# Reverse engineering time!
#
# Input:
#   #ip 2
#   seti 123 0 4       #  0: r4 = 123
#   bani 4 456 4       #  1: r4 &= 456
#   eqri 4 72 4        #  2: r4 = (r4 == 72) ? 1 : 0
#   addr 4 2 2         #  3: goto 5 if r4 == 72
#   seti 0 0 2         #  4: goto 0
#   seti 0 5 4         #  5: r4 = 0
#   bori 4 65536 5     #  6: r5 = r4 | 65536
#   seti 1765573 9 4   #  7: r4 = 1765573
#   bani 5 255 1       #  8: r1 = r5 & 255
#   addr 4 1 4         #  9: r4 += r1
#   bani 4 16777215 4  # 10: r4 &= 16777215
#   muli 4 65899 4     # 11: r4 *= 65899
#   bani 4 16777215 4  # 12: r4 &= 16777215
#   gtir 256 5 1       # 13: r1 = (256 > r5) ? 1 : 0
#   addr 1 2 2         # 14: goto 16 if 256 > r5
#   addi 2 1 2         # 15: goto 17
#   seti 27 0 2        # 16: goto 28
#   seti 0 8 1         # 17: r1 = 0
#   addi 1 1 3         # 18: r3 = r1 + 1
#   muli 3 256 3       # 19: r3 *= 256
#   gtrr 3 5 3         # 20: r3 = (r3 > r5) ? 1 : 0
#   addr 3 2 2         # 21: goto 23 if r3 > r5
#   addi 2 1 2         # 22: goto 24
#   seti 25 1 2        # 23: goto 26
#   addi 1 1 1         # 24: r1 += 1
#   seti 17 7 2        # 25: goto 18
#   setr 1 4 5         # 26: r5 = r1
#   seti 7 6 2         # 27: goto 8
#   eqrr 4 0 1         # 28: r1 = (r4 == r0) ? 1 : 0
#   addr 1 2 2         # 29: halt if (r4 == r0)
#   seti 5 2 2         # 30: goto 6
#
# Converting goto -> loops:
#   begin  # 0
#     r4 = 123 & 456
#   end until r4 == 72
#   r4 = 0
#   begin  # 6
#     r5 = r4 | 65536
#     r4 = 1765573
#     loop do  # 8
#       r1 = r5 & 255
#       r4 = ((r4 + r1) & 16777215) * 65899) & 16777215
#       break if r5 < 256
#       r1 = 0
#       loop do  # 18
#         r3 = (r1 + 1) * 256
#         break if r3 > r5
#         r1 += 1
#       end
#       r5 = r1
#     end
#   end until r4 == r0
#
# Simplified:
#   begin  # 0
#     r4 = 123 & 456
#   end until r4 == 72
#   r4 = 0
#   begin  # 6
#     r5 = r4 | 65536
#     r4 = 1765573
#     loop do  # 8
#       r4 = (((r4 + (r5 & 255)) & 16777215) * 65899) & 16777215
#       break if r5 < 256
#       r5 /= 256
#     end
#   end until r4 == r0
#
# Part 1 is therefore simply what r4 is after one iteration.
#
# Part 2 is solved by checking for repetitions, choosing the last value before
# the cycle repeats.

seen = []
r4 = 0
until seen.include?(r4)
  seen << r4 unless r4 == 0
  r5 = r4 | 65536
  r4 = 1765573
  loop do
    r4 = (((r4 + (r5 & 255)) & 16777215) * 65899) & 16777215
    break if r5 < 256
    r5 /= 256
  end
  # Part 1
  if seen.empty?
    puts "Fewest instructions input: #{r4}"
  end
end

# Part 2
puts "Most instructions input: #{seen.last}"
