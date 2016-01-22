-module(liewang_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
  supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
  Parameters=lib_parameter:load("../data/"),
  liewang:start(),
  {ok, {{one_for_one, 5, 10},
    [{tag1, {building_server, start_link, [Parameters]},
      permanent,
      10000,
      worker,
      [building_server]},
      {tag2, {role_server, start_link, [Parameters]},
        permanent,
        10000,
        worker,
        [role_server]}
    ]}}.

