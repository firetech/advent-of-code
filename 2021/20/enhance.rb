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

NEIGHBOURS = [
  [-1, -1], [0, -1], [1, -1],
  [-1,  0], [0,  0], [1,  0],
  [-1,  1], [0,  1], [1,  1]
]

def enhance(image, input_void = false)
  void = @algo[(input_void ? 511 : 0)]
  fill = !void
  new_image = Hash.new(void)
  keys = image.keys
  xs = keys.map(&:first)
  ys = keys.map(&:last)
  (ys.min - 1).upto(ys.max + 1) do |y|
    (xs.min - 1).upto(xs.max + 1) do |x|
      v = 0
      NEIGHBOURS.each do |dx, dy|
        v <<= 1
        v |= 1 if image[[x + dx, y + dy]]
      end
      new_image[[x, y]] = fill if @algo[v] == fill
    end
  end
  return new_image, void
end

ITERATIONS = [
  2,  # Part 1
  50  # Part 2
]

image = @image
void = false
1.upto(ITERATIONS.max) do |steps|
  image, void = enhance(image, void)
  if ITERATIONS.include?(steps)
    raise "Infinite lit pixels" if void
    puts "Lit pixels after #{steps} iterations: #{image.count}"
  end
end
