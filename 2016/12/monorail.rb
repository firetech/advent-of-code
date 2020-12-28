require_relative '../lib/assembunny'

file = 'input'
#file = 'example1'

assembunny = AssemBunny.new(file)

# Part 1
puts "Register a value: #{assembunny.run[:a]}"

# Part 2
puts "Register a value with c initialized to 1: #{assembunny.run(c: 1)[:a]}"
