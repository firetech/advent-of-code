card = 7573546; door = 17786549
#card = 5764801; door = 17807724
BASE = 7
MOD = 20201227

card_val = 7
door_val = 7
loop_size = nil
pub = nil
i = 2
loop do
  card_val = (card_val * BASE) % MOD
  if card_val == card
    puts "Found card loop size: #{i}"
    loop_size = i
    pub = door
    break
  end

  door_val = (door_val * BASE) % MOD
  if door_val == door
    puts "Found door loop size: #{i}"
    loop_size = i
    pub = card
    break
  end

  i += 1
end

key = pub
(loop_size - 1).times do
  key = (key * pub) % MOD
end
puts "Encryption key: #{key}"
