require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@report = File.read(file).rstrip.split("\n").map do |line|
  line.split(/\s+/).map(&:to_i)
end

last_sum = 0 # Part 1
first_sum = 0 # Part 2
@report.each do |line|
  values = [line]
  begin
    diffs = []
    values.last.each_cons(2) do |l, r|
      diffs << r - l
    end
    break if diffs.all?(0)
    values << diffs
  end while diffs.length >= 2 # Just a safeguard

  # Part 1
  values.last << values.last.last
  values.reverse.each_cons(2) do |below, above|
    above << above.last + below.last
  end
  last_sum += values.first.last

  # Part 2
  values.last.unshift(values.last.first)
  values.reverse.each_cons(2) do |below, above|
    above.unshift(above.first - below.first)
  end
  first_sum += values.first.first
end

# Part 1
puts "Sum of extrapolated next values: #{last_sum}"

# Part 2
puts "Sum of extrapolated previous values: #{first_sum}"
