-module(kepler20pb).
-export([start/1, kepler20pb/2, molecule/0, generate_molecules/1, ready_to_turn_water/2]).
-import(lists, [map/2]).

kepler20pb(RttwPID, Time) ->
    generate_molecules(RttwPID),

    timer:sleep(Time * 1000),

    kepler20pb(RttwPID, Time).
ready_to_turn_water(OxygenList, HydrogenList) ->
    receive
        {oxygen, OPid} ->
            NewOxygenList = OxygenList ++ [{oxygen, OPid}],

            if (length(NewOxygenList) > 0) and (length(HydrogenList) > 1) ->
                    [Oxygen | OxygenListTail] = NewOxygenList,
                    [HydrogenOne, HydrogenTwo | HydrogenListTail] = HydrogenList,

                    io:format("~n", []),
                    io:format("The molecules (~p/~p) (~p/~p) (~p/~p) ~n", [element(1, HydrogenOne), element(2, HydrogenOne), element(1, HydrogenTwo), element(2, HydrogenTwo), element(1, Oxygen), element(2, Oxygen)]),
                    io:format("~n", []),
                    
                    ready_to_turn_water(OxygenListTail, HydrogenListTail);
                true -> true
            end,

            ready_to_turn_water(NewOxygenList, HydrogenList);
        {hydrogen, HPid} ->
            NewHydrogenList = HydrogenList ++ [{hydrogen, HPid}],

            if (length(NewHydrogenList) > 1) and (length(OxygenList) > 0) ->
                    [Oxygen | OxygenListTail] = OxygenList,
                    [HydrogenOne, HydrogenTwo | HydrogenListTail] = NewHydrogenList, 

                    io:format("~n", []),
                    io:format("The molecules (~p/~p) (~p/~p) (~p/~p) TURN WATER!~n", [element(1,HydrogenOne), element(2, HydrogenOne), element(1, HydrogenTwo), element(2, HydrogenTwo), element(1, Oxygen), element(2, Oxygen)]),
                    io:format("~n", []),

                    ready_to_turn_water(OxygenListTail, HydrogenListTail);
                true -> true
            end,

            ready_to_turn_water(OxygenList, NewHydrogenList)
    end.
molecule() ->
    receive
        {oxygen, RttwPID} ->
            io:format("CREATE: Molecule ~p of ~p is energizing ~n", [self(), oxygen]),
            timer:sleep((rand:uniform(20) + 10) * 1000),
            io:format("ENERGIZED: The molecule ~p of ~p is energized.~n", [self(), oxygen]), 

            RttwPID ! {oxygen, self()};
        {hydrogen, RttwPID} ->
            io:format("CREATE: Molecule ~p of ~p is energizing ~n", [self(), hydrogen]),
            timer:sleep((rand:uniform(20) + 10) * 1000),
            io:format("ENERGIZED: The molecule ~p of ~p is energized.~n", [self(), hydrogen]),

            RttwPID ! {hydrogen, self()}
    end.
generate_molecules(RttwPID) ->
    Random = rand:uniform(50),

    if 
        Random > 25 ->
            MOPid = spawn(kepler20pb, molecule, []),
            MOPid ! { oxygen, RttwPID };
        true -> 
            MHPid = spawn(kepler20pb, molecule, []),
            MHPid ! { hydrogen, RttwPID }
    end.
start(Time) ->
    RttwPID = spawn(kepler20pb, ready_to_turn_water, [[], []]),
    kepler20pb(RttwPID, Time).