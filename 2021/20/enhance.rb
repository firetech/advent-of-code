require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

algo_str, input_str = File.read(file).strip.split("\n\n")

@algo = Hash.new(false)
algo_str.each_char.with_index do |c, i|
  @algo[i] = true if c == '#'
end

@image = Hash.new(false)
input_str.split("\n").each_with_index do |line, y|
  line.each_char.with_index do |c, x|
    @image[y << 16 | x] = true if c == '#'
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
  min_x = 0; max_x = 0
  min_y = 0; max_y = 0
  image.each_key do |key|
    x = key & 0xFFFF
    min_x = x - 1 if x <= min_x
    max_x = x + 1 if x >= max_x
    y = key >> 16
    min_y = y - 1 if y <= min_y
    max_y = y + 1 if y >= max_y
  end
  min_y.upto(max_y) do |y|
    min_x.upto(max_x) do |x|
      v = 0
      NEIGHBOURS.each do |dx, dy|
        v <<= 1
        v |= 1 if image[(y + dy) << 16 | (x + dx)]
      end
      new_image[(y - min_y) << 16 | (x - min_x)] = fill if @algo[v] == fill
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
