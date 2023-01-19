require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'
#file = 'example2'

input = File.read(file).strip.split("\n")

# Part 1
abba = '([[:lower:]])((?!\1)[[:lower:]])\2\1'
supports_tls = input.count do |ip|
  ip =~ /#{abba}/ and not ip =~ /\[[^\]]*#{abba}[^\]]*\]/
end
puts "#{supports_tls} IPs support TLS"

# Part 2
first = '([[:lower:]])((?!\1)[[:lower:]])\1'
second = '\2\1\2'
supports_ssl = input.count do |ip|
  ip =~ /(?:\A|\])(?:[^\[]*)#{first}.*\[[^\]]*#{second}[^\]]*\]/ or
    ip =~ /\[[^\]]*#{first}(?:[^\]]*?\][^\[]*?\[)*[^\]]*?\][^\[]*?#{second}/
end
puts "#{supports_ssl} IPs support SSL"

