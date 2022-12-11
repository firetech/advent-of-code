input = File.read('input')

@steps = []
input.strip.split("\n").each do |line|
  case line
  when 'deal into new stack'
    @steps << [:rev]
  when /\Acut (-?\d+)\z/
    @steps << [:cut, Regexp.last_match[1].to_i]
  when /\Adeal with increment (\d+)\z/
    @steps << [:inc, Regexp.last_match[1].to_i]
  else
    raise "Malformed line: #{line}"
  end
end

# Graciously stolen from Rosetta Code (https://rosettacode.org/wiki/Modular_inverse#Ruby)
def modinv(a, m) # compute a^-1 mod m if possible
  raise "NO INVERSE - #{a} and #{m} not coprime" unless a.gcd(m) == 1
  return m if m == 1
  m0, inv, x0 = m, 1, 0
  while a > 1
    inv -= (a / m) * x0
    a, m = m, a % m
    inv, x0 = x0, inv
  end
  inv += m0 if inv < 0
  return inv
end

def apply(steps, deck)
  cards = deck.length
  steps.each do |op, arg|
    case op
    when :rev
      deck = deck.reverse
    when :cut
      deck = deck.rotate(arg)
    when :inc
      inv = modinv(arg, cards)
      deck = deck.each_index.map { |i| deck[(i * inv) % cards] }
    end
  end
  return deck
end

# part 1
after_shuffle = apply(@steps, (0...10007).to_a)
puts "Position of card 2019: #{after_shuffle.index(2019)}"


# part 2
def simplify_step(steps, i, cards)
  return if i >= steps.length - 1
  op1, arg1 = steps[i]
  op2, arg2 = steps[i + 1]
  case [op1, op2]
  when [:rev, :rev]
    # merge by eliminating
    steps[i, 2] = []
  when [:cut, :cut]
    # merge by adding args
    steps[i, 2] = [
      [:cut, (arg1 + arg2) % cards]
    ]
  when [:inc, :inc]
    # merge by multiplying args
    steps[i, 2] = [
      [:inc, (arg1 * arg2) % cards]
    ]
  when [:rev, :cut]
    # invert order to move pairs of the same operation together
    steps[i, 2] = [
      [:cut, -arg2],
      steps[i]
    ]
  when [:rev, :inc]
    # invert order to move pairs of the same operation together
    # needs an additional :cut, though
    steps[i, 2] = [
      steps[i + 1],
      [:cut, -arg2 + 1],
      steps[i]
    ]
  when [:cut, :inc]
    # invert order to move pairs of the same operation together
    steps[i, 2] = [
      steps[i + 1],
      [:cut, (arg1 * arg2) % cards]
    ]
  end
end

def simplify(steps, cards)
  last = nil
  steps = steps.dup
  until steps == last
    last = steps.dup
    steps.each_index { |i| simplify_step(steps, i, cards) }
  end
  return steps
end

after_simplified_shuffle = apply(simplify(@steps, 10007), (0...10007).to_a)
if after_simplified_shuffle != after_shuffle
  raise "Simplification doesn't produce identical results"
end


cards = 119315717514047
steps = simplify(@steps, cards)

n = 101741582076661
pow = 1
bits = {}
while pow < n
  bits[pow] = steps
  pow <<= 1
  steps = simplify(steps + steps, cards)
end

bits_of_n = bits.keys.select { |b| n & b == b }
if bits_of_n.sum != n
  raise "Sum of bits is not the same as value"
end

pos = 2020
simplify(bits_of_n.flat_map { |b| bits[b] }, cards).reverse_each do |op, arg|
  case op
  when :rev
    pos = cards - 1 - pos
  when :cut
    pos = (pos + arg) % cards
  when :inc
    pos = (pos * modinv(arg, cards)) % cards
  end
end
puts "Card at position 2020: #{pos}"
