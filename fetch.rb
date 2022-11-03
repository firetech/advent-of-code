#!/usr/bin/env ruby

require 'net/http'
require 'optparse'

$year = Time.now.year
today = Time.now.strftime('%Y/%d')
$requests = []
$opts = OptionParser.new do |opts|

  opts.on('-y',
          '--year=YEAR',
          'Year to fetch data for (default current year)') do |y|
    $year = y
  end

  opts.on('-i',
          '--input=DAY[:FILE]',
          "Fetch input for day DAY to FILE (default 'input'), DAY '.' will " \
            "get year and day from current directory (e.g. #{today})") do |d|
    day, file = d.split(':')
    file ||= 'input'
    year = $year
    if day == '.'
      dir = Dir.pwd.sub(/\A#{Regexp.escape(__dir__)}\//, '')
      year, day, *extra = dir.split('/')
      unless year =~ /\A\d{4}\z/ and day =~ /\A\d{1,2}\z/ and extra.empty?
        STDERR.puts "Did you run this in a day folder (i.e. #{today})?"
        exit 1
      end
    end
    day.sub!(/\A0+/, '') # Remove leading zeroes
    $requests << ["/#{year}/day/#{day}/input", file]
  end

  opts.on('-l',
          '--leaderboard=ID[:FILE]',
          'Fetch private leaderboard ID to FILE (default \'ID.json\')') do |l|
    id, file = l.split(':')
    file ||= "#{id}.json"
    raise "Bad id '#{id}'" unless id =~ /\A\d+\z/
    $requests << ["/#{$year}/leaderboard/private/view/#{id}.json", file]
  end

  opts.on('-h', '--help', 'Print this help and exit.') do
    usage(false)
  end

  opts.separator ''
  opts.separator 'If no -i or -l options are given, the default is ' \
                   'equivalent to \'-i .\'.'
  opts.separator 'If you specify \'-\' where a FILE is expected, the data ' \
                   'will be output to STDOUT instead.'

end

def usage(spacer = true)
  puts if spacer
  STDERR.puts $opts
  exit false
end

begin
  $opts.parse!(ARGV)
  $opts.parse!(['--input=.']) if $requests.empty?
rescue => e
  STDERR.puts e
  usage
end

def get_session(force_prompt = false)
  session_file = File.join(__dir__, '.session')
  if File.exist?(session_file) and not force_prompt
    session = File.read(session_file).strip
  else
    print 'Please supply your session ID: '
    session = gets.strip
    File.open(session_file, 'w') do |f|
      f.puts session
    end
  end
  return session
end

$session = get_session
options = {
  open_timeout: 2,
  read_timeout: 10,
  ssl_timeout: 2,
  use_ssl: true
}
Net::HTTP.start('adventofcode.com', 443, nil, options) do |http|
  $requests.each do |request_uri, file|
    if file == '-'
      file = :STDOUT
    end
    STDERR.puts "Fetching #{request_uri} to #{file}..."
    req = Net::HTTP::Get.new(request_uri)
    req['cookie'] = "session=#{$session}"
    body = nil
    begin
      do_retry = false
      http.request(req) do |response|
        if response.is_a?(Net::HTTPSuccess)
          if file == :STDOUT
            puts response.body
          else
            File.open(file, 'w') do |f|
              f.puts response.body
            end
          end
        elsif response.is_a?(Net::HTTPBadRequest)
          puts response.body
          puts
          puts "Session seems to have expired."
          $session = get_session(true)
          do_retry = true
        else
          puts response.body
          exit 1
        end
      end
    end while do_retry
  end
end
