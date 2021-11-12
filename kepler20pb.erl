-module(kepler20pb).
-export([start/0, oxygen/0, hydrogen/0]).

start() ->
    spawn(oxygen, oxygen, []),
    timer:sleep(1000),
    start().
oxygen() ->
    io:format("Oxygen", []).
hydrogen() ->
    io:format("Hydrogen", []).