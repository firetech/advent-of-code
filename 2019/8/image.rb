input = File.read('input').strip.chars.map(&:to_i)
WIDTH = 25
HEIGHT = 6

layers = input.each_slice(WIDTH*HEIGHT).to_a

# part 1
counts = layers.map do |l|
  [l.count(0), l.count(1)*l.count(2)]
end
zeroes, others = counts.min_by { |zeroes, others| zeroes }
puts "count(1)*count(2) = #{others}"

# part 2
layers.map! { |l| l.each_slice(WIDTH).to_a }
img = Array.new(HEIGHT) { Array.new(WIDTH, 2) }
layers.each do |layer|
  layer.each_with_index do |line, y|
    line.each_with_index do |val, x|
      if img[y][x] == 2
        img[y][x] = val
      end
    end
  end
end

# Intended for a white-on-black terminal
puts
img.each do |line|
  line.each do |pixel|
    case pixel
    when 0
      print ' '
    when 1
      print '#'
    else
      raise "Unexpected value: #{pixel}"
    end
  end
  puts
end
