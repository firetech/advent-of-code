require 'set'

input = File.read('input').split("\n")
#input = File.read('example1').split("\n")
#input = File.read('example2').split("\n")

@rules = {}
input.each do |line|
  if line =~ /\A(.+) bags contain ((\d+ .+ bags?(, )?)+|no other bags).\z/
    outer = Regexp.last_match(1)
    if @rules.has_key?(outer)
      raise "Duplicate rule for '#{outer}'"
    end
    if Regexp.last_match(2) == 'no other bags'
      @rules[outer] = nil
    else
      @rules[outer] = {}
      Regexp.last_match(2).lstrip.split(', ').each do |content|
        if content =~ /\A(\d+) (.+) bags?\z/
          inner = Regexp.last_match(2)
          if @rules[outer].has_key?(inner)
            raise "Duplicate content '#{inner}' for '#{outer}'"
          end
          @rules[outer][inner] = Regexp.last_match(1).to_i
        else
          raise "Malformed inner rule: '#{content}'"
        end
      end
    end
  else
    raise "Malformed line: '#{line}'"
  end
end

#part 1
parents = {}
@rules.each do |outer, contents|
  next if contents.nil?
  contents.each_key do |inner|
    parents[inner] ||= []
    parents[inner] << outer
  end
end
to_check = ['shiny gold']
checked = Set.new
count = -1 # don't count the shiny gold bag
while not to_check.empty?
  bag = to_check.shift
  next if checked.include?(bag)
  checked << bag
  count += 1
  if parents.has_key?(bag)
    to_check += parents[bag]
  end
end
puts "#{count} bag colors eligible to contain shiny gold bags."

#part 2
@content_count = {}
def count_bags(outer)
  if not @content_count.has_key?(outer)
    @content_count[outer] = 1
    if not @rules[outer].nil?
      @rules[outer].each do |inner, count|
        @content_count[outer] += count_bags(inner) * count
      end
    end
  end
  return @content_count[outer]
end
puts "#{count_bags('shiny gold') - 1} bags required inside a shiny gold bag."
