require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'
#file = 'example2'
#file = 'example3'

def parse(str)
  depth = -1
  num = ''
  list = []
  str.each_char do |c|
    case c
    when '['
      depth += 1
    when ',', ']'
      list << [num.to_i, depth] unless num.empty?
      num = ''
      depth -= 1 if c == ']'
    when /\A\d\z/
      num << c
    else
      raise "Unexpected character '#{c}'"
    end
  end
  return list
end

def add(a, b)
  return reduce((a + b).map { |num, depth| [num, depth + 1] })
end

def reduce(x)
  loop do
    did_explode = explode(x)
    next if did_explode
    did_split = split(x)
    break unless did_split
  end
  return x
end

def explode(x)
  x.each_with_index do |(left_num, depth), i|
    if depth >= 4
      right_num, right_depth = x[i+1]
      raise "Depth mismatch" if right_depth != depth
      x[i-1][0] += left_num if i > 0
      x[i+2][0] += right_num if i < x.length - 2
      x[i, 2] = [[0, depth - 1]]
      return true
    end
  end
  return false
end

def split(x)
  x.each_with_index do |(num, depth), i|
    if num >= 10
      s_num = num / 2
      s_depth = depth + 1
      x[i, 1] = [[s_num, s_depth], [s_num + (num.odd? ? 1 : 0), s_depth]]
      return true
    end
  end
  return false
end

def magnitude(x)
  3.downto(0) do |depth|
    i = 0
    while i < x.length - 1
      left_num, left_depth = x[i]
      if left_depth == depth
        right_num, right_depth = x[i+1]
        raise "Depth mismatch" if right_depth != left_depth
        x[i, 2] = [[left_num * 3 + right_num * 2, depth - 1]]
      end
      i += 1
    end
  end
  raise "Unexpected result" if x.length > 1 or x.first.last != -1
  return x.first.first
end

@numbers = File.read(file).strip.split("\n").map { |line| parse(line) }


# Part 1
x = @numbers.first
@numbers[1..-1].each do |n|
  x = add(x, n)
end
puts "Magnitude of final sum: #{magnitude(x)}"


# Part 2
require_relative '../../lib/multicore'

stop = nil
begin
  t = Time.now
  input, output, stop = Multicore.run do |worker_in, worker_out, t, _|
    loop do
      a, b = worker_in[]
      break if a.nil?
      worker_out[magnitude(add(a,b))]
    end
  end
  num_combs = 0
  @numbers.combination(2) do |a, b|
    input << [a, b]
    input << [b, a]
    num_combs += 2
  end
  input.close
  max = 0
  num_combs.times do
    magnitude = output.pop
    raise "Worker returned nil" if magnitude.nil?
    max = magnitude if magnitude > max
  end
  raise "Unexpected output" unless output.empty?
  puts "Part 2 calculation time: #{(Time.now - t).round(2)}s"
  puts "Largest magnitude: #{max}"
ensure
  stop[] unless stop.nil?
end
