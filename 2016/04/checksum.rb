file = 'input'
#file = 'example1'

input = File.read(file).strip.split("\n")

# Part 1
ALPHABET = ('a'..'z').to_a
def check(name, checksum)
  counts = ALPHABET.map { |c| [c, name.count(c)] }
  return checksum == counts.sort_by { |c, n| -n }.map(&:first)[0..4].join
end

valid_rooms = []
input.each do |line|
  if line =~ /\A([[:lower:]-]+)-(\d+)\[([[:lower:]]+)\]\z/
    name = Regexp.last_match(1)
    sector = Regexp.last_match(2).to_i
    checksum = Regexp.last_match(3)
    if check(name, checksum)
      valid_rooms << [name, sector]
    end
  else
    raise "Malformed line: '#{line}'"
  end
end

puts "Sum of valid sector IDs: #{valid_rooms.map(&:last).sum}"

# Part 2
def decrypt(name, sector)
  alpha_map = { '-' => '-' }
  ALPHABET.each_with_index do |c, i|
    alpha_map[c] = ALPHABET[(i + sector) % ALPHABET.length]
  end
  return name.each_char.map { |c| alpha_map[c] }.join
end
valid_rooms.each do |name, sector|
  name = decrypt(name, sector)
  if name =~ /north-?pole/
    puts "Sector ID of '#{name}': #{sector}"
  end
end
