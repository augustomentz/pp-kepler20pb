-module(kepler20pb).
-export([start/0, kepler20pb/2, molecule/2, generate_molecules/1, ready_to_turn_water/1]).
-import(lists, [map/2]).

kepler20pb(_, 0) ->
    io:format("No have more molecules of Oxygens and Hydrogens at Kepler82.~n", []);
kepler20pb(RttwPID, N_MOLECULES) ->
    generate_molecules(RttwPID),

    timer:sleep(500),

    kepler20pb(RttwPID, N_MOLECULES - 1).

ready_to_turn_water(State) ->
    receive
        {Type} ->
            NewList = lists:append(State, Type),

            map(fun(X) -> io:format("~s ~n", [X]) end, NewList),

            ready_to_turn_water(NewList)
    end.
molecule(Molecule_Type, RttwPID) ->
    io:format("A molecule ~p of ~s is energizing ~n", [self(), Molecule_Type]),
    timer:sleep((rand:uniform(2) + 4) * 1000),
    io:format("The molecule ~p of ~s is energized.~n", [self(), Molecule_Type]),

    RttwPID ! { [Molecule_Type] }.

generate_molecules(RttwPID) ->
    Random = rand:uniform(50),

    if 
        Random > 25 ->
            spawn(kepler20pb, molecule, ["OXYGEN", RttwPID]);
        true -> 
            spawn(kepler20pb, molecule, ["HYDROGEN", RttwPID])
    end.
start() ->
    RttwPID = spawn(kepler20pb, ready_to_turn_water, [[]]),
    kepler20pb(RttwPID, 3).