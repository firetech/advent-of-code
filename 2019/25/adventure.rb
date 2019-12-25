input = File.read('input').strip

require_relative '../lib/intcode'

@commands = <<EOF
west
west
north
take space heater
south
east
south
south
take sand
north
north
east
east
take mug
east
south
east
south
take easter egg
north
west
west
south
west
south
south
EOF
@commands = @commands.lines

@droid = Intcode.new(input, false)
@droid.run do
  while @droid.has_output?
    print @droid.output.chr
  end

  if @commands.empty?
    line = gets
  else
    line = @commands.shift
    print line
  end
  line.chars.map(&:ord)
end
# Realizing I needed this loop took me embarrasingly long...
while @droid.has_output?
  print @droid.output.chr
end
