file = 'input'
#file = 'example1'
#file = 'example2'
#file = 'example3'

def add(a, b)
  reduce([a,b])
end

def reduce(x)
  loop do
    did_explode, x = explode(x)
    next if did_explode
    did_split, x = split(x)
    break unless did_split
  end
  return x
end

def explode(x, parents = 0)
  if x.is_a?(Array)
    left, right = x
    if parents < 4
      did_explode, new_left, l_add, r_add = explode(left, parents + 1)
      return true, [new_left, add_right(right, r_add)], l_add, 0 if did_explode
      did_explode, new_right, l_add, r_add = explode(right, parents + 1)
      return true, [add_left(left, l_add), new_right], 0, r_add if did_explode
    else
      return true, 0, left, right
    end
  end
  return false, x, 0, 0
end

def add_left(x, add)
  return x if add == 0
  if x.is_a?(Array)
    left, right = x
    return [left, add_left(right, add)]
  else
    return x + add
  end
end

def add_right(x, add)
  return x if add == 0
  if x.is_a?(Array)
    left, right = x
    return [add_right(left, add), right]
  else
    return x + add
  end
end

def split(x)
  if x.is_a?(Array)
    left, right = x
    did_split, new_left = split(left)
    return true, [new_left, right] if did_split
    did_split, new_right = split(right)
    return true, [left, new_right] if did_split
  else
    if x >= 10
      new_x = x / 2
      return true, [new_x, new_x + (x.odd? ? 1 : 0)]
    end
  end
  return false, x
end

def magnitude(x)
  if x.is_a?(Array)
    left, right = x
    return 3 * magnitude(left) + 2 * magnitude(right)
  else
    return x
  end
end

@numbers = File.read(file).strip.split("\n").map { |line| eval(line) }


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
