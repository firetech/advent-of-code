require_relative '../../lib/aoc_api'
require_relative '../lib/intcode'

input = File.read(ARGV[0] || AOC.input_file()).strip

@droid = Intcode.new(input, false)

def run_program(program, verbose)
  @droid.reset
  thread = Thread.new { @droid.run }
  while @droid.has_output? or not @droid.waiting_for_input?
    output = @droid.output
    print output.chr if verbose
  end

  program.each_char do |c|
    print c if verbose
    @droid << c.ord
  end

  while @droid.has_output? or @droid.running?
    output = @droid.output
    if output < 128
      print output.chr if verbose
    else
      return output
    end
  end
  return nil
ensure
  thread.kill
end

# part 1
program1 = <<EOF
NOT A T
NOT B J
OR J T
NOT C J
OR T J
AND D J
WALK
EOF
puts "Hull damage (WALK): #{run_program(program1, false) or 'FAIL'}"

# part 2
program2 = <<EOF
NOT A T
NOT B J
OR J T
NOT C J
OR T J
AND D J
NOT J T
OR E T
OR H T
AND T J
RUN
EOF
puts "Hull damage (RUN): #{run_program(program2, false) or 'FAIL'}"

