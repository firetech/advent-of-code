Advent of Code
==============

My solutions to [Advent of Code](http://adventofcode.com). Mainly for my own entertainment. I make no claims that these are good solutions.

So far, all my solutions have been implemented in pure Ruby.


Utilities & Libraries
=====================

I've also included some utilities and custom libraries in this repository.

fetch.rb
--------
Fetches input data (preventing paste errors) or private leaderboard JSON data.

leaderboard.rb
--------------
Parses private leaderboard JSON data and outputs some interesting statisticts:

* Individual top list for each star.
* A matrix of players and their solution times for each star.
* A top list that sorts players (with the same amount of stars) on the total time taken between solving part 1 and part 2 for each day. Can easily be gamed with multiple accounts, but doesn't require people to start working on the puzzles immediately when they unlock.

skeleton.rb
-----------
My starting point for each puzzle. Contains the stuff I mostly add to my solutions.

run\_year.rb
------------
Runs the main solution (shortest filename) for every day of a given year, with a timer running for each.

Includes an optional rehearsal mode similar to the [bmbm function](https://ruby-doc.org/current/stdlibs/benchmark/Benchmark.html#method-c-bmbm) of Ruby's Benchmark library.

lib/aoc.rb
----------
Library for communicating with adventofcode.com. Mainly for getting the input automatically using `AOC.input_file()`.

lib/aoc\_math.rb
----------------
Library containing common math features used in a few solutions.

lib/priority\_queue.rb
----------------------
A simple (but still sufficiently fast) priority queue implementation in pure Ruby. About as fast as other pure Ruby implementations I've found, but has no dependencies.

lib/multicore.rb
----------------
Library for running processing on multiple CPU cores.

Threading isn't sufficient in normal Ruby due to the Global Interpreter Lock limiting execution to only one thread at a time. To achieve true parallelism, we need to fork (which doesn't work in Windows). Also compatibile with JRuby (which does have true parallelism, but can't fork).

This library is **NOT** recommended for everyday use (forking can be quite expensive), but works well in this context.


Automation Information
======================

This repo follows the [automation guidelines](https://www.reddit.com/r/adventofcode/wiki/faqs/automation) on the [/r/adventofcode](https://www.reddit.com/r/adventofcode) community wiki. Specifically:

* Throttling of requests (a minimum of 5 minutes between outbound calls) _from within the same process_ is implemented: [lib/aoc.rb, lines 20-39](lib/aoc.rb#L20) (Within this repo, this really only affects [run\_year.rb](run_year.rb), which also has code to handle this throttling despite utilizing forking. No other script does more than one outbound call at a time.)
* The `User-Agent` header contains information linking it to the creator of this repo: [lib/aoc.rb, lines 66-68](lib/aoc.rb#L66)
* Inputs are cached on successful download: [lib/aoc.rb, lines 120-123](lib/aoc.rb#L120)
