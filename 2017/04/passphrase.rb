require_relative '../../lib/aoc_api'

input = File.read(ARGV[0] || AOC.input_file()).strip
#input = File.read('example1').strip
#input = File.read('example2').strip

lines = input.split("\n")
valid1 = 0
valid2 = 0
lines.each do |line|
  words = line.split(/\s+/)
  if words.uniq.length == words.length
    valid1 += 1
    anagrams = []
    words.each do |word|
      chars = word.chars.sort
      if anagrams.include?(chars)
        break
      end
      anagrams << chars
    end
    if anagrams.length == words.length
      valid2 += 1
    end
  end
end

# Part 1
puts "#{valid1} passwords without repeated words"

# Part 2
puts "#{valid2} passwords without repeated anagrams"
