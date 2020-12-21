file = 'input'
#file = 'example1'

@input = File.read(file).strip.split("\n").map(&:to_i)

def best_qe(groups)
  target_weight = @input.inject(0) { |sum, x| sum + x } / groups

  n = (target_weight / @input.max.to_f).ceil.to_i
  group1 = nil
  while group1.nil?
    qe = []
    @input.combination(n) do |group|
      if group.inject(0) { |sum, x| sum + x } == target_weight
        qe << group.inject(1) { |prod, x| prod * x }
      end
    end
    if not qe.empty?
      return qe.min
    end
    n += 1
  end
  raise "Ehm..."
end

# Part 1
puts "Ideal quantum entanglement (3 groups): #{best_qe(3)}"

# Part 2
puts "Ideal quantum entanglement (4 groups): #{best_qe(4)}"
