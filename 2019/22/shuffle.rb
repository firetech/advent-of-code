input = File.read('input'); CARDS = 10007
#input = File.read('example'); CARDS = 10 

# part 1
@deck = (0...CARDS).to_a
input.strip.split("\n").each do |line|
  case line
  when 'deal into new stack'
    @deck.reverse!
  when /\Acut (-?\d+)\z/
    cut = Regexp.last_match[1].to_i
    @deck = @deck[cut..-1] + @deck[0...cut]
  when /\Adeal with increment (\d+)\z/
    step = Regexp.last_match[1].to_i
    new_deck = Array.new(@deck.length)
    i = 0
    until @deck.empty?
      new_deck[i] = @deck.shift
      unless @deck.empty?
        until new_deck[i].nil?
          i = (i + step) % new_deck.length
        end
      end
    end
    @deck = new_deck
  end
end

puts "Position of card 2019: #{@deck.index(2019)}"
