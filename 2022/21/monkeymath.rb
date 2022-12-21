file = ARGV[0] || 'input'
#file = 'example1'

@monkeys = {}
File.read(file).rstrip.split("\n").each do |line|
  case line
  when /\A(.*): (\d+)\z/
    @monkeys[Regexp.last_match(1).to_sym] = Regexp.last_match(2).to_i
  when /\A(.*): (.*) ([+\-*\/]) (.*)\z/
    @monkeys[Regexp.last_match(1).to_sym] = [
      Regexp.last_match(2).to_sym,
      Regexp.last_match(3).to_sym,
      Regexp.last_match(4).to_sym
    ]
  else
    raise "Malformed line: '#{line}'"
  end
end

def monkey_value(monkey)
  val = @monkeys[monkey]
  case val
  when Array
    str = "(#{monkey_value(val[0])} #{val[1]} #{monkey_value(val[2])})"
    begin
      str = eval(str).to_s
    rescue Exception
      # ignore
    end
    return str
  when Integer, Symbol
    return val
  else
    raise 'Ehm?'
  end
end

puts "Root monkey yells #{eval(monkey_value(:root))}"
puts

@monkeys[:humn] = :x
val1 = monkey_value(@monkeys[:root][0])
val2 = monkey_value(@monkeys[:root][2])

if val1.include?('x')
  puts "#{val1} = #{eval(val2)}"
elsif val2.include?('x')
  puts "#{eval(val1)} = #{val2}"
end

puts "Paste on https://www.mathpapa.com/equation-solver/ to get answer"
