input = File.read('input').strip.split("\n")
#input = File.read('example').strip.split("\n")
#input = File.read('example2').strip.split("\n")

#part 1
@orbiters = {}
input.each do |line|
  if line =~ /\A(.+)\)(.+)\z/
    a = Regexp.last_match[1]
    b = Regexp.last_match[2]
    @orbiters[a] ||= []
    @orbiters[a] << b
  else
    raise "Malformed line: #{line}"
  end
end

level = 1
list = [ 'COM' ]
count = 0
while not list.empty?
  next_list = []
  list.each do |body|
    orbiters = @orbiters[body]
    if not orbiters.nil?
      count += orbiters.count * level
      next_list += orbiters
    end
  end
  level += 1
  list = next_list
end

puts "#{count} direct and indirect orbits found"

#part 2
@orbits = {}
input.each do |line|
  if line =~ /\A(.+)\)(.+)\z/
    a = Regexp.last_match[1]
    b = Regexp.last_match[2]
    @orbits[b] = a
  else
    raise "Malformed line: #{line}"
  end
end

common = nil
from_me = [@orbits['YOU']]
from_san = [@orbits['SAN']]
while common.nil?
  next_me = @orbits[from_me.last]
  if not next_me.nil?
    if from_san.include?(next_me)
      common = next_me
    end
    from_me << next_me
  end

  if common.nil?
    next_san = @orbits[from_san.last]
    if not next_san.nil?
      if from_me.include? next_san
        common = next_san
      end
      from_san << next_san
    end
  end

  if next_me.nil? and next_san.nil?
    raise 'Couldn\'t find common center'
  end
end

puts "Transfers needed: #{from_me.index(common) + from_san.index(common)}"

