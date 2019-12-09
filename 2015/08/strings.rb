input = File.read('input').strip.split("\n")

#part 1
diff = input.map do |line|
  line.length - eval(line).length
end

puts "Total diff (eval): #{diff.inject(0) { |sum, x| sum + x }}"

#part 2
diff2 = input.map do |line|
  line.inspect.length - line.length
end

puts "Total diff (inspect): #{diff2.inject(0) { |sum, x| sum + x }}"
