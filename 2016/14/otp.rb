require 'digest/md5'

input = 'cuanljph'
#input = 'abc'

def find_64th
  index = 0
  candidates = Array.new(16) { [] }
  found = []

  while found.length < 64
    hash = yield index
    hash.scan(/([0-9a-f])\1\1\1\1/) do |c|
      c = c[0].to_i(16)
      found += candidates[c].reject { |i| i <= index - 1000 }
      candidates[c].clear
    end
    if hash =~ /([0-9a-f])\1\1/
      candidates[Regexp.last_match(1).to_i(16)] << index
    end
    index += 1
  end
  return found.sort[63]
end

# Part 1
index1 = find_64th do |index|
  Digest::MD5.hexdigest(input + index.to_s)
end
puts "Index of 64th one-time pad key: #{index1}"

# Part 2
index2 = find_64th do |index|
  hash = Digest::MD5.hexdigest(input + index.to_s)
  2016.times { hash = Digest::MD5.hexdigest(hash) }
  hash
end
puts "Index of 64th one-time pad key with stretching: #{index2}"
