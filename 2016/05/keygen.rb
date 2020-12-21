require 'digest/md5'

input = 'wtnhxymk'
#input = 'abc'

# Part 1
password = []
found_hashes = []
i = 0
8.times do |p|
  while password[p].nil?
    hash = Digest::MD5.hexdigest("#{input}#{i}")
    if hash =~ /\A00000/
      puts "> Found #{hash}"
      password[p] = hash[5]
      found_hashes << hash
    end
    i += 1
  end
end
puts "Password: #{password.join}"

# Part 2
def fill_password(password, hash)
  pos = hash[5]
  if ('0'..'7').include?(pos)
    pos = pos.to_i
    if password[pos].nil?
      password[pos] = hash[6]
    end
  end
end
improved_password = [ nil ] * 8
found_hashes.each { |hash| fill_password(improved_password, hash) }
while improved_password.include?(nil)
  hash = Digest::MD5.hexdigest("#{input}#{i}")
  if hash =~ /\A00000/
    puts "> Found #{hash}"
    fill_password(improved_password, hash)
  end
  i += 1
end
puts "Improved password: #{improved_password.join}"
