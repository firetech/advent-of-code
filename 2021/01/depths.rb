file = 'input'
#file = 'example1'

larger = 0
last = nil
windows = [[], [], []]
larger_windows = 0
last_window = nil
File.read(file).strip.split("\n").each do |line|
  this = line.to_i

  # Part 1
  if not last.nil? and this > last
    larger += 1
  end
  last = this

  # Part 2
  windows.each do |window|
    window << this
    if window.length == 3
      sum = window.sum
      if not last_window.nil? and sum > last_window
        larger_windows += 1
      end
      last_window = sum
      window.shift
    end
  end
end

# Part 1
puts "#{larger} measurements are larger than the previous"

# Part 2
puts "#{larger_windows} windows are larger than the previous"
