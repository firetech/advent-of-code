require 'set'

file = 'input'
#file = 'example1'
#file = 'example2'
#file = 'example3'

class Cuboid
  attr_reader :x_min, :x_max, :y_min, :y_max, :z_min, :z_max
  def initialize(x_min, x_max, y_min, y_max, z_min, z_max)
    @x_min = x_min
    @x_max = x_max
    @y_min = y_min
    @y_max = y_max
    @z_min = z_min
    @z_max = z_max
  end

  def intersects?(other)
    return ([@x_min, other.x_min].max < [@x_max, other.x_max].min and
        [@y_min, other.y_min].max < [@y_max, other.y_max].min and
        [@z_min, other.z_min].max < [@z_max, other.z_max].min)
  end

  def slice_with(other)
    return [] unless intersects?(other)
    slices = []
    xs = [@x_min, other.x_min, @x_max, other.x_max].uniq.sort
    ys = [@y_min, other.y_min, @y_max, other.y_max].uniq.sort
    zs = [@z_min, other.z_min, @z_max, other.z_max].uniq.sort
    xs.each_cons(2) do |s_x_min, s_x_max|
      ys.each_cons(2) do |s_y_min, s_y_max|
        zs.each_cons(2) do |s_z_min, s_z_max|
          slices << Cuboid.new(
            s_x_min, s_x_max,
            s_y_min, s_y_max,
            s_z_min, s_z_max
          )
        end
      end
    end
    return slices
  end

  def size
    (@x_max - @x_min) * (@y_max - @y_min) * (@z_max - @z_min)
  end

  def hash
    [@x_min, @x_max, @y_min, @y_max, @z_min, @z_max].hash
  end

  def eql?(other)
    return false unless other.is_a?(Cuboid)
    return (@x_min == other.x_min and @x_max == other.x_max and
        @y_min == other.y_min and @y_max == other.y_max and
        @z_min == other.z_min and @z_max == other.z_max)
  end
end

@on_cuboids = Set[]
File.read(file).strip.split("\n").each do |line|
  case line
  when /\A(on|off) x=(-?\d+)..(-?\d+),y=(-?\d+)..(-?\d+),z=(-?\d+)..(-?\d+)\z/
    on = Regexp.last_match(1) == 'on'
    x_min, x_max = Regexp.last_match(2).to_i, Regexp.last_match(3).to_i + 1
    y_min, y_max = Regexp.last_match(4).to_i, Regexp.last_match(5).to_i + 1
    z_min, z_max = Regexp.last_match(6).to_i, Regexp.last_match(7).to_i + 1
    new_cuboid = Cuboid.new(x_min, x_max, y_min, y_max, z_min, z_max)
    @on_cuboids.to_a.each do |cuboid|
      # Slice up intersection into smaller cuboids, add all slices that only
      # intersect with the old cuboid
      slices = cuboid.slice_with(new_cuboid)
      next if slices.empty?
      @on_cuboids.delete(cuboid)
      slices.each do |slice|
        if cuboid.intersects?(slice) and not new_cuboid.intersects?(slice)
          @on_cuboids << slice
        end
      end
    end
    @on_cuboids << new_cuboid if on
  else
    raise "Malformed line: '#{line}'"
  end
end

pp @on_cuboids.sum(&:size)
