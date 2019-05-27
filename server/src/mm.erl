-module(mm).
-export([
         % to be used by players (?)
         carne_pa_canhao/1,

         % to be used by matches
         match_over/2,

         start/0,
         stop/0
        ]).

start() ->
    Pid = spawn(fun() -> mm(init()) end),
    register(?MODULE, Pid),
    ok.

stop() ->
    srv:stop(?MODULE).

stop(Ps) ->
    [ cl:stop(P) || P <- Ps ],
    ok.

init() ->
    {[], []}.

mm({[P2, P1 | Rest], Matches}) ->
    Match = match:new(P1, P2),
    cl:enter_match(P1, Match),
    cl:enter_match(P2, Match),
    mm({Rest, [Match|Matches]});
mm({Ps, Matches}=State) ->
    receive
        stop ->
            [ match:stop(Match) || Match <- Matches ],
            stop(Ps),
            ok;
        {call, {Pid, Ref}=From, Msg}
          when is_pid(Pid),
               is_reference(Ref) ->
            mm(handle_call(State, From, Msg));
        {cast, Msg} ->
            mm(handle_cast(State, Msg));
        Msg ->
            io:format("Unexpected message: ~p\n", [Msg])
    end.

handle_call(State, From, _Msg) ->
    srv:reply(From, sup),
    State.

handle_cast({Ps, Matches}, {carne_pa_canhao, Xixa}) ->
    {[Xixa|Ps], Matches};
handle_cast({Ps, Matches}, {match_over, Match, P1, P2}) ->
    {[P1, P2 | Ps], Matches -- [Match]};
handle_cast(State, Msg) ->
    io:format("Unexpected message: ~p\n", [Msg]),
    State.

carne_pa_canhao(Xixa) ->
    srv:cast(?MODULE, {carne_pa_canhao, Xixa}).

match_over(P1, P2) ->
    srv:cast({match_over, self(), P1, P2}).