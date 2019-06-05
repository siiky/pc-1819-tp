-module(ts).
-export([
         new_score/1,
         top_score/0,

         start/0,
         stop/0
        ]).

start() ->
    Pid = spawn(fun() -> ts([]) end),
    register(?MODULE, Pid),
    ok.

stop() ->
    srv:stop(?MODULE).

ts(Scores) ->
    receive
        stop -> ok;
        {call, From, Msg} ->
            ts(handle_call(Scores, From, Msg));
        {cast, Msg} ->
            ts(handle_cast(Scores, Msg));
        Msg ->
            io:format("ts:ts:unexpected: ~p\n", [Msg]),
            ts(Scores)
    end.

handle_call(Scores, From, top_score) ->
    srv:reply(From, Scores),
    Scores;
handle_call(Scores, From, Msg) ->
    srv:reply(From, unexpected),
    io:format("Unexpected message: ~p\n", [Msg]),
    Scores.

handle_cast(Scores, {new_score, CRLH}) ->
    NewScores = take(5, insert(Scores, CRLH)),
    SerScore = scores_to_string(NewScores),
    mm:updated_scores(SerScore),
    NewScores;
handle_cast(Scores, Msg) ->
    io:format("ts:cast:unexpected: ~p\n", [Msg]),
    Scores.

new_score(CRLH) ->
    srv:cast(?MODULE, {new_score, CRLH}).

top_score() ->
    srv:recv(srv:call(?MODULE, top_score)).

insert([], SP) ->
    [SP];
insert([H|T], SP) ->
    case H > SP of
        true -> [H|insert(T, SP)];
        false -> [SP,H|T]
    end.

take(N, L) -> lists:sublist(L, N).

scores_to_string(Scores) ->
    lists:join(" ", lists:map(fun({CRLH, N}) -> [ integer_to_list(CRLH), ":", N] end, Scores)).
