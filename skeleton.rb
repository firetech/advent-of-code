require_relative '../../lib/aoc_api'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

File.read(file).rstrip.split("\n").each do |line|
  case line
  when /\A\z/
    
  else
    raise "Malformed line: '#{line}'"
  end
end
