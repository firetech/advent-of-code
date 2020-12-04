input = File.read('input')
#input = File.read('example1')

input = input.strip.split("\n\n").map do |data|
  passport = {}
  data.scan(/(\S+):(\S+)/) do |key,val|
    passport[key] = val
  end
  passport
end

#part 1
fields = %w(byr iyr eyr hgt hcl ecl pid)
valid = input.select do |passport|
  fields.all? { |f| passport.has_key?(f) }
end
puts "#{valid.count} valid passports found"

#part 2
def check_yr(data, min, max)
  return (data =~ /\A\d{4}\z/ and (min..max).include?(data.to_i))
end
def check_hgt(data)
  if data =~ /\A(\d+)cm\z/
    return (150..193).include?(Regexp.last_match(1).to_i)
  elsif data =~ /\A(\d+)in\z/
    return (59..76).include?(Regexp.last_match(1).to_i)
  end
  return false
end

ecls = %w(amb blu brn gry grn hzl oth)
valid2 = valid.count do |p|
  check_yr(p['byr'], 1920, 2002) and
    check_yr(p['iyr'], 2010, 2020) and
    check_yr(p['eyr'], 2020, 2030) and
    check_hgt(p['hgt']) and
    p['hcl'] =~ /\A#[0-9a-f]{6}\z/ and
    ecls.include?(p['ecl']) and
    p['pid'] =~ /\A[0-9]{9}\z/
end
puts "#{valid2} actually valid passports found"
