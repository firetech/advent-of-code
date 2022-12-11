input = File.read('input').strip
#input = File.read('example1').strip
#input = File.read('example2').strip

sheet = input.split("\n").map { |line| line.split(/\s+/).map(&:to_i) }

# Part 1
chksum = sheet.sum { |line| line.max - line.min }
puts "Spreadsheet checksum: #{chksum}"

# Part 2
divsum = sheet.sum do |line|
  div = 0
  line.combination(2) do |a, b|
    if a % b == 0
      div = a / b
      break
    elsif b % a == 0
      div = b / a
      break
    end
  end
  div
end

puts "Sum of divisible numbers: #{divsum}"
