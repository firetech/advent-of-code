file = 'input'
#file = 'example1'

@input = File.read(file).strip.split("\n").map(&:to_i)

def best_qe(groups)
  target_weight = @input.sum / groups

  n = (target_weight / @input.max.to_f).ceil.to_i
  loop do
    qe = []
    @input.combination(n) do |group|
      if group.sum == target_weight
        qe << group.inject(&:*)
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
