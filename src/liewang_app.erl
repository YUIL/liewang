-module(liewang_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    liewang_sup:start_link().

stop(_State) ->
    gen_server:stop(login_server,close,1000),
    io:format("liwang stop!~n"),
    ok.
