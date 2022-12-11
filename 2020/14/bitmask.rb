file = 'input'
#file = 'example1'
#file = 'example2'

input = File.read(file).strip.split("\n")

##########
# Part 1 #
##########
@all1 = (1 << 36) - 1
@val_mask0 = @all1
@val_mask1 = 0

def parse_val_mask(mask)
  mask0 = 0
  mask1 = 0
  mask.each_char do |bit|
    mask0 <<= 1
    mask1 <<= 1
    case bit
    when 'X'
      mask0 |= 1
    when '1'
      mask1 |= 1
    end
  end
  @val_mask0 = mask0
  @val_mask1 = mask1
end

def mask_val(val)
  return val & @all1 & @val_mask0 | @val_mask1
end

mem = {}
input.each do |line|
  if line =~ /\Amask = ([X01]{36})\z/
    parse_val_mask(Regexp.last_match(1))
  elsif line =~ /\Amem\[(\d+)\] = (\d+)\z/
    mem[Regexp.last_match(1).to_i] = mask_val(Regexp.last_match(2).to_i)
  else
    raise "Malformed line: '#{line}'"
  end
end
puts "Sum of memory values (value masking): #{mem.values.sum}"

##########
# Part 2 #
##########
@addr_mask1 = 0
@addr_maskf = @all1
@addr_floating = []
def parse_addr_mask(mask)
  mask1 = 0
  maskf = 0
  floating = []
  mask.each_char.with_index do |bit, i|
    mask1 <<= 1
    maskf <<= 1
    case bit
    when 'X'
      maskf |= 1
      floating << 35 - i
    when '1'
      mask1 |= 1
    end
  end
  if floating.length > 10
    raise "More than 10 floating bits in mask '#{mask}' (running on first example data?)"
  end
  @addr_mask1 = mask1
  @addr_maskf = ~maskf
  @addr_floating = (0..floating.length).flat_map { |n| floating.combination(n).to_a }.map do |bits|
    bits.map { |bit| 1 << bit }.inject(0, &:|)
  end
end

def mask_addr(addr)
  static_part = addr & @addr_maskf | @addr_mask1
  return @addr_floating.map { |mask| static_part | mask }
end

mem = {}
input.each do |line|
  if line =~ /\Amask = ([X01]{36})\z/
    parse_addr_mask(Regexp.last_match(1))
  elsif line =~ /\Amem\[(\d+)\] = (\d+)\z/
    mask_addr(Regexp.last_match(1).to_i).each do |addr|
      mem[addr] = Regexp.last_match(2).to_i
    end
  else
    raise "Malformed line: '#{line}'"
  end
end
puts "Sum of memory values (address masking): #{mem.values.sum}"
