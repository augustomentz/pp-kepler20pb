-module(kepler20pb).
-export([start/0, kepler20pb/1, molecule/1, generate_molecules/0, ready_to_turn_water/0]).

kepler20pb(0) ->
    io:format("Finished.~n", []);
kepler20pb(N_MOLECULES) ->
    generate_molecules(),

    timer:sleep(500),

    kepler20pb(N_MOLECULES - 1).

ready_to_turn_water() ->
    List = [],
    receive
        {ready, List} ->
            erlang:insert_element(1, List, 'z'),
            % lists:append(List, {Molecule_PID, Molecule_Type}),
            io:format("~p", [element(1, List)])
    end.

molecule(Molecule_Type) ->
    io:format("A molecule ~p of ~s is energizing ~n", [self(), Molecule_Type]),
    timer:sleep((rand:uniform(20) + 10) * 1000),
    io:format("The molecule ~p of ~s is energized.~n", [self(), Molecule_Type]),

    RttwPID = spawn(kepler20pb, ready_to_turn_water, []),
    RttwPID ! { ready, {self(), Molecule_Type} }.

generate_molecules() ->
    Random = rand:uniform(50),

    if 
        Random > 25 ->
            spawn(kepler20pb, molecule, ["OXYGEN"]);
        true -> 
            spawn(kepler20pb, molecule, ["HYDROGEN"])
    end.
start() ->
    kepler20pb(20).