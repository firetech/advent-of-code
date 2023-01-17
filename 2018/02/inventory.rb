require_relative '../../lib/aoc_api'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@boxes = File.read(file).strip.split("\n")

# Part 1
counts = Hash.new(0)
@boxes.each do |id|
  char_count = Hash.new(0)
  id.each_char do |char|
    char_count[char] += 1
  end
  char_count.values.uniq.each do |val|
    counts[val] += 1
  end
end

puts "List checksum: #{counts[2] * counts[3]}"

# Part 2
common_id = nil
@boxes.each_with_index do |box1, i|
  @boxes[i..-1].each do |box2|
    mismatch = nil
    box1.each_char.with_index do |char, c|
      if box2[c] != char
        if mismatch.nil?
          mismatch = c
        else
          mismatch = nil
          break
        end
      end
    end
    unless mismatch.nil?
      common_id = box1.clone
      common_id[mismatch] = ''
      break
    end
  end
  break unless common_id.nil?
end

puts "Common id letters: #{common_id}"
