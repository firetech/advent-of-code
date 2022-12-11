input = File.read('input').strip.split("\n")

# Part 1
diff = input.map do |line|
  line.length - eval(line).length
end

puts "Total diff (eval): #{diff.sum}"

# Part 2
diff2 = input.map do |line|
  line.inspect.length - line.length
end

puts "Total diff (inspect): #{diff2.sum}"
