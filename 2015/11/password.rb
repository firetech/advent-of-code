input = 'hepxcrrq'
#input = 'abcdefgh'
#input = 'ghijklmn'

#part 1
@letters = ('a'..'z').to_a
@straights = @letters.each_cons(3).to_a.map(&:join)

def pw_bad?(pw)
  if pw =~ /i|o|l/
    return true
  end
  if not pw =~ /(.)\1.*(.)\2/
    return true
  end
  if not @straights.map { |str| pw.include? str }.include?(true)
    return true
  end
  return false
end

def next_pw(pw)
  bad_index = pw.index(/i|o|l/)
  if not bad_index.nil?
    pw = pw[0..bad_index] + ('z' * (pw.length - bad_index - 1))
  end
  index = pw.each_char.map do |c|
    @letters.index(c)
  end
  begin
    new_index = []
    index.reverse.each do |i|
      new_i = i
      begin
        new_i += 1
      end while @letters[new_i] =~ /\Ai|o|l\z/
      done = true
      if new_i >= @letters.length
        new_i = 0
        done = false
      end
      new_index.unshift new_i
      if done
        break
      end
    end
    if new_index.length < index.length
      new_index = index[0..(index.length - new_index.length - 1)] + new_index
    end
    new_pw = new_index.map { |i| @letters[i] }.join('')
    index = new_index
  end while pw_bad?(new_pw)
  return new_pw
end

new_pw = next_pw(input)
puts "New password: #{new_pw}"

#part 2
puts "New password (again): #{next_pw(new_pw)}"
