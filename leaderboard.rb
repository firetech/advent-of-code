#!/usr/bin/env ruby
# Advent of Code Private Leaderboard JSON parser.
# Supply JSON (https://adventofcode.com/2021/leaderboard/private/view/XXXX.json)
# as a file or STDIN (default)

require 'optparse'
require 'json'

# Parse command line arguments
$stars = []
$top = nil
$include_empty = false
$filter = nil
$opts = OptionParser.new do |opts|
  opts.banner = "Usage: #{opts.program_name} [options] [filename]"

  opts.separator ''
  opts.separator 'Will read JSON from STDIN if filename is not supplied.'

  opts.separator ''
  opts.separator 'Options:'


  opts.on('-s', '--star=DAY-STAR', 'Show individual leaderboard for DAY-STAR. Can be specified multiple times') do |s|
    if s =~ /\A(\d+)-([1-2])\z/
      $stars << [Regexp.last_match(1).to_i, Regexp.last_match(2).to_i]
    else
      raise "Invalid star: '#{s}'"
    end
  end

  opts.on('-t', '--top=TOP', 'Limit to top TOP players.') do |t|
    $top = t.to_i
  end

  opts.on('-e', '--empty', 'Include players with no stars.') do
    $include_empty = true
  end

  opts.on('-f', '--filter=FILTER', 'Members filter. Will be eval()ed in a block where member data is available as the variable m.') do |f|
    $filter = f
  end

  opts.on_tail('-h', '--help', 'Print this help and exit.') do
    usage(false)
  end
end

def usage(spacer = true)
  puts "" if spacer
  STDERR.puts $opts
  exit false
end

def name(m)
  n = (m['name'] or "(##{m['id']})")
  if n.length > 25
    n = "#{n[0,22]}..."
  end
  return n
end

def print_table(table)
  length = Array.new(table.first.length, 0)
  table.each do |line|
    line.each_with_index { |v, i| length[i] = [length[i], v.length].max }
  end
  table.each do |line|
    line.each_with_index do |v, i|
      print '  ' unless i == 0
      print "%-#{length[i]}s" % v
    end
    puts
  end
end

begin
  $opts.parse!(ARGV)
rescue => e
  STDERR.puts e
  usage
end

unless $*[1].nil?
  STDERR.puts "Unexpected argument '#{$*[1]}'!"
  usage
end

if $*[0].nil? or $*[0] == '-'
  json = STDIN.read
else
  json = File.read($*[0])
end

board = JSON.parse(json)

unless board.has_key?('members')
  raise "Is this really an Advent of Code leaderboard JSON?"
end

members = board['members'].values
unless $include_empty
  members.select! { |m| not m['completion_day_level'].empty? }
end
if $filter
  members.select! { |m| eval($filter) }
end

if $stars.empty?
  # Print table of solve times per star (with at least one solve)
  members.sort_by! { |m| -m['local_score'] }
  members = members.first($top) unless $top.nil?
  days = members.flat_map { |m| m['completion_day_level'].keys }.uniq
  table = [[ ' * ', *members.map { |m| name(m) } ]]
  days.sort_by(&:to_i).each do |day|
    1.upto(2) do |star|
      member_times = members.map do |m|
        if m['completion_day_level'].has_key?(day.to_s) and
            m['completion_day_level'][day.to_s].has_key?(star.to_s)
          t = m['completion_day_level'][day.to_s][star.to_s]['get_star_ts']
          Time.at(t).strftime('%Y-%m-%d %H:%M:%S')
        else
          ''
        end
      end
      table << [ "#{day}-#{star}", *member_times ]
    end
  end
  print_table(table)
else

  # Print toplist for each supplied star
  $stars.each_with_index do |(day, star), index|
    puts if index > 0
    if $stars.length > 1
      title = "Star #{day}-#{star}"
      puts title
      puts '=' * title.length
    end
    table_members = members.select do |m|
      m['completion_day_level'].has_key?(day.to_s) and
        m['completion_day_level'][day.to_s].has_key?(star.to_s)
    end
    table_members.sort_by! do |m|
      m['completion_day_level'][day.to_s][star.to_s]['get_star_ts']
    end
    table_members = table_members.first($top) unless $top.nil?
    table = table_members.map.with_index do |m, i|
      t = m['completion_day_level'][day.to_s][star.to_s]['get_star_ts']
      [ (i + 1).to_s, name(m), Time.at(t).strftime('%Y-%m-%d %H:%M:%S') ]
    end
    print_table(table)
  end
end
