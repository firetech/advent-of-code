Advent of Code
==============

My solutions to Advent of Code. Mainly for my own entertainment. I make no claims that these are good solutions.

I usually use Ruby as my language of choice, with possible exceptions for when another language is more appropriate for a specific task.

Utilities
=========

I've also included some utilities in this repository.

fetch.rb
--------
Fetches input data (preventing paste errors) or private leaderboard JSON data.

leaderboard.rb
--------------
Parses private leaderboard JSON data and outputs some interesting statisticts:

* Individual top list for each star.
* A matrix of players and their solution times for each star.
* A top list that sorts players (with the same amount of stars) on the total time taken between solving part 1 and part 2 for each day. Can easily be gamed with multiple accounts, but doesn't require people to start working on the puzzles immediately when they unlock.
