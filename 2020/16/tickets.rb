file = 'input'
#file = 'example1'

input = File.read(file).strip.split("\n")

fields = []
valid_fields = {}
state = :fields
my_ticket = nil
tickets = []
input.each do |line|
  case line
  when /\A(.*): (\d+)-(\d+) or (\d+)-(\d+)\z/
    field = Regexp.last_match(1)
    fields << field
    [
      (Regexp.last_match(2).to_i..Regexp.last_match(3).to_i),
      (Regexp.last_match(4).to_i..Regexp.last_match(5).to_i)
    ].each do |range|
      range.each do |val|
        valid_fields[val] ||= []
        valid_fields[val] << field
      end
    end
  when /\Ayour ticket:\z/
    state = :mine
  when /\Anearby tickets:\z/
    state = :others
  when /\A(\d+,?)+\z/
    ticket = line.split(',').map(&:to_i)
    if state == :mine and my_ticket.nil?
      my_ticket = ticket
    elsif state == :others
      tickets << ticket
    else
      raise "Unexpected ticket: '#{line}'"
    end
  when ''
    # ignore
  else
    raise "Malformed line: '#{line}'"
  end
end


# Part 1
invalid_sum = 0
valid_tickets = tickets.select do |ticket|
  is_valid = true
  ticket.each do |val|
    if not valid_fields.has_key?(val)
      invalid_sum += val
      is_valid = false
    end
  end
  is_valid
end
puts "Ticket scanning error rate: #{invalid_sum}"


# Part 2
possible_fields = Array.new(my_ticket.length) { fields.clone }
valid_tickets.each do |ticket|
  ticket.each_with_index do |val, i|
    possible_fields[i] &= valid_fields[val]
  end
end
definite_fields = []
while possible_fields.count([]) < possible_fields.length
  possible_fields.each_with_index do |fields, i|
    if fields.length == 1
      definite_fields[i] = fields.first
      possible_fields.map! do |other_fields|
        other_fields - fields
      end
    end
  end
end
departure_product = 1
definite_fields.each_with_index do |field, i|
  if field =~ /\Adeparture/
    departure_product *= my_ticket[i]
  end
end
puts "Departure product: #{departure_product}"
