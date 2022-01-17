file = ARGV[0] || 'input'
#file = 'example1'

File.read(file).strip.split("\n").each do |line|
  case line
  when /\A\z/
    
  else
    raise "Malformed line: '#{line}'"
  end
end
