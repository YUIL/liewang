%%%-------------------------------------------------------------------
%%% @author yuil
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. 一月 2016 22:16
%%%-------------------------------------------------------------------
-module(main_server).
-author("yuil").
-include("./role.hrl").

-behavior(gen_server).
%% API
-export([start_link/0, handle_call/3, handle_cast/2, handle_info/2, code_change/3, terminate/2, init/1]).
start_link() ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
  %%读取存档
  _RoleTable = case filelib:is_file("../data/role_table.tab") of
                 true ->
                   ets:file2tab("../data/role_table.tab");
                 false ->
                   ets:new(role_table, [set, public, named_table])
               end,
  _BuildingTable = case filelib:is_file("../data/building_table.tab") of
                     true ->
                       ets:file2tab("../data/building_table.tab");
                     false ->
                       ets:new(building_table, [set, public, named_table])
                   end,
  State =  case filelib:is_file("../data/login_server.sta") of
             true ->
               {ok,Bin}=file:read_file("../data/login_server.sta"),
               binary_to_term(Bin);
             false ->
               1
           end,
  io:format("login_server started!!~n"),
  {ok, State}.

handle_call(close, _From, N) ->
  io:format("recv:lose~n"),
  exit(server_close);

handle_call(login, _From, N) ->
  io:format("login!~n"),
  add_role(N),
  Reply = {login(N), N},
  {reply, Reply, N + 1};

handle_call({login, RoleId}, _From, N) ->
  io:format("~p login!~n", [RoleId]),
  case is_login(RoleId) of
    true ->
      Reply = {error, is_login};
    false ->
      Reply = login(RoleId)
  end,
  {reply, Reply, N};

handle_call(add_role, _From, N) ->
  io:format("add_role!~n"),
  Reply = add_role(N),
  {reply, Reply, N + 1}.

handle_cast(_msg, State) ->
  {noreply, State}.

handle_info(_Info, State) ->
  {noreply, State}.

code_change(_OldVsn, N, _Extra) ->
  {ok, N}.

terminate(_Reason, State) ->
  ets:tab2file(role_table, "../data/role_table.tab"),
  ets:tab2file(building_table, "../data/building_table.tab"),
  file:write_file("../data/login_server.sta",term_to_binary(State)),
  application:stop(liewang),
  ok.

add_role(RoleId) ->
  ets:insert(role_table, {RoleId, #role{role_id = RoleId, name = "role" ++ integer_to_list(RoleId)}}),
  ok.

login(RoleId) ->
  RoleServerName = list_to_atom("role_server" ++ integer_to_list(RoleId)),
  BuildingServerName = list_to_atom("building_server" ++ integer_to_list(RoleId)),
  Servers = dict:store(role_server, RoleServerName,
    dict:store(building_server, BuildingServerName, dict:new())),
  %%启动玩家的gen_server
  {ok, _RoleServer} = role_server:start(Servers),
  {ok, _BuildingServer = building_server:start(Servers)},
  ok.

is_login(RoleId) ->
  RoleServerName = list_to_atom("role_server" ++ integer_to_list(RoleId)),
  is_pid(whereis(RoleServerName)).
