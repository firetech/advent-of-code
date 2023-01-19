require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'
#file = 'example2'

NEXT_DIR = {
  '|' =>  { up: :up, down: :down },
  '-' =>  { left: :left, right: :right },
  '\\' => { up: :left, down: :right, left: :up, right: :down },
  '/' =>  {  up: :right, down: :left, left: :down, right: :up },
  '+' =>  Hash.new(:cart) # Any key will return :cart
}

CART_INPUT = {
  '^' => [:up, '|'],
  'v' => [:down, '|'],
  '<' => [:left, '-'],
  '>' => [:right, '-']
}
CART_TO_S = CART_INPUT.transform_values { |d, r| d }.invert

class Cart
  attr_reader :x, :y, :dir

  TURNS = [
    { up: :left, down: :right, left: :down, right: :up },
    { up: :up, down: :down, left: :left, right: :right },
    { up: :right, down: :left, left: :up, right: :down }
  ]

  def initialize(x, y, dir)
    @x = x
    @y = y
    @dir = dir
    @next_turn = 0
  end

  def move(map)
    case @dir
    when :up
      @y -= 1
    when :down
      @y += 1
    when :left
      @x -= 1
    when :right
      @x += 1
    else
      raise "Unknown direction: #{dir.inspect}"
    end
    next_dir = (NEXT_DIR[map[y][x]] or {})[@dir]
    raise "I'm lost! @(#{@x}, #{@y})" if next_dir.nil?
    if next_dir == :cart
      next_dir = TURNS[@next_turn][@dir]
      @next_turn = (@next_turn + 1) % TURNS.length
    end
    @dir = next_dir
  end

  def crash?(other)
    other != self and @x == other.x and @y == other.y
  end

  def to_s
    "#<Cart x:#{@x}, y: #{@y}, dir: #{@dir}>"
  end
end

def print_map(carts = [], crash_x = nil, crash_y = nil)
  map_str = @map.map.with_index do |line, y|
    line_str = line.map.with_index do |c, x|
      if x == crash_x and y == crash_y
        'X'
      else
        cart = carts.find { |cart| cart.x == x and cart.y == y }
        if cart.nil?
          c
        else
          CART_TO_S[cart.dir]
        end
      end
    end
    line_str.join
  end
  puts map_str.join("\n")
end

@carts = []
@map = File.read(file).rstrip.split("\n").map.with_index do |line, y|
  line.chars.map.with_index do |c, x|
    if CART_INPUT.has_key?(c)
      dir, replacement = CART_INPUT[c]
      @carts << Cart.new(x, y, dir)
      replacement
    else
      c
    end
  end
end
@width = @map.first.length

carts = @carts
first_crash_found = false
while carts.length > 1
  removed = []
  carts.sort_by { |cart| cart.y * @width + cart.x }.each do |cart|
    next if removed.include?(cart)
    begin
      cart.move(@map)
    rescue => e
      print_map(carts)
      puts cart
      raise e
    end
    crash_cart = carts.find { |other_cart| cart.crash?(other_cart) }
    unless crash_cart.nil?
      unless first_crash_found
        #print_map(carts, cart.x, cart.y)
        puts "Location of first crash: #{cart.x},#{cart.y}"
        first_crash_found = true
      end
      removed << crash_cart
      removed << cart
    end
  end
  carts = carts.select { |cart| not removed.include?(cart) }
end
#print_map(carts)
puts "Location of last remaining cart: #{carts.first.x},#{carts.first.y}"
