require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

print "Parsing input..."
@start_state = nil
@diag_steps = nil
@ops = {}
current_state = nil
current_value = nil
File.read(file).strip.split("\n").each do |line|
  case line
  when /\ABegin in state ([A-Z]+)\.\z/
    raise "Duplicated begin" unless @start_state.nil?
    @start_state = Regexp.last_match(1)
  when /\APerform a diagnostic checksum after (\d+) steps\.\z/
    raise "Duplicated step count" unless @diag_steps.nil?
    @diag_steps = Regexp.last_match(1).to_i
  when ''
    # Ignore
  when /\AIn state ([A-Z]+):\z/
    state = Regexp.last_match(1)
    raise "Duplicated state #{state}" if @ops.has_key?(state)
    current_state = {}
    @ops[state] = current_state
  when /\A\s+If the current value is ([0-1]):\z/
    value = Regexp.last_match(1).to_i
    raise "Duplicated value #{value}" if current_state.has_key?(value)
    current_value = Array.new(3)
    current_state[value] = current_value
  when /\A\s+- Write the value ([0-1])\.\z/
    raise "Duplicated write" unless current_value[0].nil?
    current_value[0] = Regexp.last_match(1).to_i
  when /\A\s+- Move one slot to the (right|left)\.\z/
    raise "Duplicated move" unless current_value[1].nil?
    current_value[1] = (Regexp.last_match(1) == 'right') ? 1 : -1
  when /\A\s+- Continue with state ([A-Z])\.\z/
    raise "Duplicated next state" unless current_value[2].nil?
    current_value[2] = Regexp.last_match(1)
  else
    raise "Malformed line: '#{line}'"
  end
end
puts " Done."

print "Running..."
@mem = Hash.new(0)
@pos = 0
state = @start_state
@diag_steps.times do
  val, move, state = @ops[state][@mem[@pos]]
  @mem[@pos] = val
  @pos += move
end
puts " Done."

puts "Diagnostic checksum: #{@mem.values.count(1)}"
