file = ARGV[0] || 'input'
#file = 'example1'

CHAR_VAL = {
  '2' => 2,
  '1' => 1,
  '0' => 0,
  '-' => -1,
  '=' => -2
}

sum = File.read(file).rstrip.split("\n").sum do |line|
  line.each_char.inject(0) { |val, x| val * 5 + CHAR_VAL[x] }
end

def to_snafu(x)
  return '' if x == 0
  mod = x % 5
  case mod
  when 0..2
    "#{to_snafu(x/5)}#{mod}"
  when 3
    "#{to_snafu((x + 2) / 5)}="
  when 4
    "#{to_snafu((x + 1) / 5)}-"
  end
end

puts "Sum in SNAFU: #{to_snafu(sum)}"
