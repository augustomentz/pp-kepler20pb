-module(kepler20pb).
-export([start/1, kepler20pb/3, molecule/0, generate_molecules/1, ready_to_turn_water/2, create_water/2]).
-import(lists, [map/2]).
kepler20pb(_,0,_) ->
    io:format("Finished", []);
kepler20pb(RttwPID, N_MOLCULES, Time) ->
    generate_molecules(RttwPID),

    timer:sleep(Time * 1000),

    kepler20pb(RttwPID, N_MOLCULES - 1, Time).
ready_to_turn_water(OxygenList, HydrogenList) ->
    receive
        {oxygen, OPid} ->
            NewOxygenList = OxygenList ++ [{oxygen, OPid}],

            if (length(NewOxygenList) > 0) and (length(HydrogenList) > 1) ->
                OxygenHydrogenTuple = create_water(NewOxygenList, HydrogenList),

                ready_to_turn_water(element(1, OxygenHydrogenTuple), element(2, OxygenHydrogenTuple));     
                true -> true
            end,

            ready_to_turn_water(NewOxygenList, HydrogenList);
        {hydrogen, HPid} ->
            NewHydrogenList = HydrogenList ++ [{hydrogen, HPid}],

            if (length(OxygenList) > 0) and (length(HydrogenList) > 1) ->
                OxygenHydrogenTuple = create_water(OxygenList, NewHydrogenList),

                ready_to_turn_water(element(1, OxygenHydrogenTuple), element(2, OxygenHydrogenTuple));
                true -> true
            end,

            ready_to_turn_water(OxygenList, NewHydrogenList)
    end.
create_water(OxygenList, HydrogenList) ->
    [Oxygen | OxygenListTail] = OxygenList,
    [HydrogenOne, HydrogenTwo | HydrogenListTail] = HydrogenList,

    io:format("~n", []),
    io:format("The molecules (~p/~p) (~p/~p) (~p/~p) are created a new water molecule!~n", [element(1, HydrogenOne), element(2, HydrogenOne), element(1, HydrogenTwo), element(2, HydrogenTwo), element(1, Oxygen), element(2, Oxygen)]),
    io:format("~n", []),

    {OxygenListTail, HydrogenListTail}.
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
    kepler20pb(RttwPID, 10, Time).