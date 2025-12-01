module AOC
  def self.session(force_prompt = false)
    session_file = File.join(__dir__, '..', '.session')
    if File.exist?(session_file) and not force_prompt
      token = File.read(session_file).strip
    else
      print 'Please supply your session ID: '
      token = gets.strip
      File.open(session_file, 'w') do |f|
        f.puts token
      end
    end
    return token
  end

  @@last_fetch = nil
  FETCH_MIN_WAIT = 300

  def self.last_fetch
    @@last_fetch
  end

  def self.update_last_fetch(new_time = Time.now)
    if not new_time.is_a? Time
      raise ArgumentError, "Expected Time, got #{new_time.class.name}"
    end
    if not @@last_fetch.nil? and new_time < @@last_fetch
      raise ArgumentError, "Blocked attempt to turn back throttle clock"
    end
    @@last_fetch = new_time
  end

  def self.fetch(*args)
    time_since_last = last_fetch.nil? ? Float::INFINITY : Time.now - last_fetch
    if time_since_last < FETCH_MIN_WAIT
      wait_time = FETCH_MIN_WAIT - time_since_last
      puts "Throttling fetch() call for #{wait_time.round} seconds..."
      sleep wait_time
    end
    if args.length == 1 and args.first.is_a?(Array)
      requests = args.first
    elsif args.length == 2 and args.all?(String)
      requests = [args]
    else
      raise ArgumentError,
            "wrong number or type of arguments (given #{args.length}, " \
              "expected 1 Array or 2 Strings)"
    end

    require 'net/http'

    token = session
    options = {
      open_timeout: 2,
      read_timeout: 10,
      ssl_timeout: 2,
      use_ssl: true
    }
    Net::HTTP.start('adventofcode.com', 443, nil, options) do |http|
      requests.each do |request_uri, file|
        if file == '-'
          file = :STDOUT
        end
        STDERR.puts "Fetching #{request_uri} to #{file}..."
        req = Net::HTTP::Get.new(request_uri)
        req['User-Agent'] = 'AOC.fetch(), ' \
                            'from github.com/firetech/advent-of-code, ' \
                            'by aoc(at)[github_username](dot)nu'
        begin
          req['cookie'] = "session=#{token}"
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
              token = session(true)
              do_retry = true
            else
              raise response.body
            end
          end
        end while do_retry
      end
    end
    update_last_fetch
  end


  def self.input_file(day = nil, year = nil)
    base = File.expand_path('..', __dir__)
    inputs = File.join(base, '.inputs')
    if not File.directory?(inputs)
      require 'fileutils'
      FileUtils.mkdir_p(inputs)
    end
    year = Time.now.year if year.nil?
    if day.nil?
      c = 0
      begin
        pwd = File.dirname(File.expand_path(caller_locations[c].path))
        c += 1
      end while pwd == __dir__
      year, day, *extra = pwd.sub(/\A#{Regexp.escape(base)}\//, '').split('/')
      unless year =~ /\A\d{4}\z/ and day =~ /\A\d{1,2}\z/ and extra.empty?
        STDERR.puts "Did you run AOC.input_file() in a puzzle folder " \
                    "(i.e. #{Time.now.strftime('%Y/%d')})?"
        exit 1
      end
    end
    day = '%02i' % day.to_i # Make sure single digit days are zero-padded.
    file = File.join(inputs, "#{year}-#{day}.txt")
    if not File.exist?(file)
      fetch("/#{year}/day/#{day.to_i}/input", file)
    end
    return file
  end


  def self.input(day = nil, year = nil)
    return File.read(input_file(day, year)).rstrip
  end
end
