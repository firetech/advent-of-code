file = 'input'
#file = 'example1'

algo_str, input_str = File.read(file).strip.split("\n\n")

@algo = Hash.new(false)
algo_str.each_char.with_index do |c, i|
  @algo[i] = true if c == '#'
end

@image = Hash.new(false)
input_str.split("\n").each_with_index do |line, y|
  line.each_char.with_index do |c, x|
    @image[[x, y]] = true if c == '#'
  end
end

def enhance(image, pad)
  new_image = Hash.new(false)
  keys = image.keys
  xs = keys.map(&:first)
  ys = keys.map(&:last)
  # Account for infinite light pixels on odd iterations
  padding = pad ? 3 : -1
  (ys.min - padding).upto(ys.max + padding) do |y|
    (xs.min - padding).upto(xs.max + padding) do |x|
      v = 0
      [
        [-1, -1],
        [ 0, -1],
        [ 1, -1],
        [-1,  0],
        [ 0,  0],
        [ 1,  0],
        [-1,  1],
        [ 0,  1],
        [ 1,  1]
      ].each do |dx, dy|
        px, py = x + dx, y + dy
        v <<= 1
        v |= 1 if image[[px, py]]
      end
      new_image[[x, y]] = true if @algo[v]
    end
  end
  return new_image
end

ITERATIONS = [
  2,  # Part 1
  50  # Part 2
]

image = @image
2.step(ITERATIONS.max, 2) do |steps|
  image = enhance(enhance(image, true), false)
  if ITERATIONS.include?(steps)
    puts "Lit pixels after #{steps} iterations: #{image.count}"
  end
end
