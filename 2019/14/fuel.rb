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
    need_chem, need_amount = need.shift
    if need_chem == 'ORE'
      ores += need_amount
    else
      if (have[need_chem] or 0) > 0
        take = [have[need_chem], need_amount].min
        have[need_chem] -= take
        need_amount -= take
      end
      if need_amount > 0
        data = @transforms[need_chem]
        times = (need_amount.to_f / data[:amount]).ceil
        data[:input].each do |src_chem, src_amount|
          need[src_chem] = (need[src_chem] or 0) + src_amount * times
        end
        remaining = (data[:amount] * times) - need_amount
        if remaining > 0
          have[need_chem] = (have[need_chem] or 0) + remaining
        end
      end
    end
  end
  return ores
end

# part 1
puts "#{get_ores(1)} ORE needed for 1 FUEL"

# part 2
TRILLION = 1000000000000
# Find first amount of FUEL that _exceeds_ a trillion ORE (due to how bsearch() works)
fuel = (0..TRILLION).bsearch { |fuel_amount| get_ores(fuel_amount) >= TRILLION }
# Reduce by one to get max amount of FUEL below a trillion ORE
puts "#{fuel - 1} FUEL can be produced with a trillion ORE"
