input = File.read('input').strip
#input = 'D2FE28'
#input = '38006F45291200'
#input = 'EE00D40C823060'
#input = 'C200B40A82'
#input = '9C0141080250320F1802104A08'

@bit_str = ''
input.each_char do |c|
  case c
  when /\A[0-9A-Z]\z/
    @bit_str << '%04b' % c.to_i(16)
  else
    raise "Malformed char: '#{c}'"
  end
end

@version_sum = 0  # Part 1
def read_packet(str, offset = 0)
  version = str[offset, 3].to_i(2)
  @version_sum += version
  offset += 3
  type = str[offset, 3].to_i(2)
  offset += 3

  if type == 4
    value_str = ''
    begin
      group = str[offset, 5]
      value_str << group[1, 4]
      offset += 5
    end while group[0] == '1'
    value = value_str.to_i(2)
  else
    length_type = str[offset, 1]
    offset += 1
    values = []
    if length_type == '0'
      bit_length = str[offset, 15].to_i(2)
      offset += 15
      target_offset = offset + bit_length
      while offset < target_offset
        child_value, offset = read_packet(str, offset)
        values << child_value
      end
      raise "overflow" if offset > target_offset
    else
      num_children = str[offset, 11].to_i(2)
      offset += 11
      num_children.times do
        child_value, offset = read_packet(str, offset)
        values << child_value
      end
    end
    # Part 2
    case type
    when 0
      value = values.sum
    when 1
      value = values.inject(&:*)
    when 2
      value = values.min
    when 3
      value = values.max
    when 5
      value = (values.first > values.last) ? 1 : 0
    when 6
      value = (values.first < values.last) ? 1 : 0
    when 7
      value = (values.first == values.last) ? 1 : 0
    end
  end
  return value, offset
end

value, offset = read_packet(@bit_str)

# Part 1
puts "Sum of packet versions: #{@version_sum}"

# Part 2
puts "Value of outermost packet: #{value}"
