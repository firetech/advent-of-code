input = File.read('input').strip
#input = File.read('example1').strip
#input = File.read('example2').strip

sheet = input.split("\n").map { |line| line.split(/\s+/).map(&:to_i) }

chksum = sheet.inject(0) do |sum, line|
  sum + (line.max - line.min)
end

puts "Spreadsheet checksum: #{chksum}"

divsum = sheet.inject(0) do |sum, line|
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
  sum + div
end

puts "Sum of divisible numbers: #{divsum}"
