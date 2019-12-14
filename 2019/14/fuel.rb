input = File.read('input')
#input = File.read('example')
#input = File.read('example2')

@transforms = {}
input.strip.split("\n").each do |line|
  if line =~ /\A((\d+ \w+(, )?)+) => (\d+) (\w+)\z/
    from = {}
    Regexp.last_match[1].split(', ').each do |f|
      parts = f.split(' ')
      from[parts[1]] = parts[0].to_i
    end
    to = Regexp.last_match[5]
    amount = Regexp.last_match[4].to_i
    if @transforms.has_key? to
      raise "Duplicate transforms for #{to}"
    end
    @transforms[to] = {
      amount: amount,
      input: from
    }
  else
    raise "Malformed line: #{line}"
  end
end


def get_ores(fuel_amount)
  need = { 'FUEL' => fuel_amount }
  have = {}
  ores = 0
  while not need.empty?
    to, amount = need.shift
    if to == 'ORE'
      ores += amount
    else
      if have.has_key?(to) and have[to] > 0
        take = [have[to], amount].min
        have[to] -= take
        amount -= take
      end
      if amount > 0
        data = @transforms[to]
        times = Rational(amount, data[:amount]).ceil
        data[:input].each do |from, from_amount|
          from_amount *= times
          if have.has_key?(from)
            take = [have[from],from_amount].min
            have[from] -= take
            from_amount -= take
          end
          if from_amount > 0
            need[from] = (need[from] or 0) + from_amount
          end
        end
        remaining = (data[:amount] * times) - amount
        if remaining > 0
          have[to] = (have[to] or 0) + remaining
        end
      end
    end
  end
  return ores
end

# part 1
puts "#{get_ores(1)} ORE needed for 1 FUEL"

# part 2
# Find first amount of fuel that exceeds a trillion ore, then reduce by one
fuel = (0..1000000000).bsearch { |fuel_amount| get_ores(fuel_amount) >= 1000000000000 } - 1
puts "#{fuel} FUEL can be produced with a trillion ORE"
