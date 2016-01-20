%%%-------------------------------------------------------------------
%%% @author i008
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. 一月 2016 18:00
%%%-------------------------------------------------------------------
-module(building_server).
-author("i008").

-include("./building.hrl").
-include("./role.hrl").
-behavior(gen_server).
%% API
-export([]).
-compile(export_all).
%%阿斯顿


start_link(Parameters) ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [Parameters], []).

init([Parameters]) ->
  State = {1, ets:new(buiding_table, [set, public, named_table]), Parameters},
  {ok, State}.


handle_call({add, Role_id, T_id}, _From, {N, Table, Parameters}) ->
  {ok, [{_MaxLevel, Each_level_parm}]} = dict:find(role, Parameters),
  {ok, Role} = gen_server:call(role_server, {get, Role_id}),
  {_Update_time, Max_nums} = lists:nth(Role#role.level, Each_level_parm),
  Max_num = lists:nth(T_id, Max_nums),
  io:format("building:~p ,Max:~p~n", [building_num(Table, Role_id, T_id), Max_num]),
  case building_num(Table, Role_id, T_id) < Max_num of
    true ->
      ets:insert(Table, {N, #building{id = N, role_id = Role_id, t_id = T_id}}),
      Reply = {ok, N};
    false ->
      Reply = {error, reached_maximum}
  end,
  {reply, Reply, {N + 1, Table, Parameters}};
handle_call({get, Id}, _From, {N, Table, Parameters}) ->
  [{_, Building} | _] = ets:lookup(Table, Id),
  Reply = {ok, Building},
  {reply, Reply, {N, Table, Parameters}};
handle_call({upgrade, Id}, _From, {N, Table, Parameters}) ->
  [{Id, Building}] = ets:lookup(Table, Id),
  ets:insert(Table, {Id, Building#building{is_upgrading = true}}),
  {ok, Building_parm} = dict:find(building, Parameters),
  {MaxLevel, Each_level_Parm} = lists:nth(Building#building.t_id, Building_parm),
  if Building#building.level < MaxLevel ->
    Reply = case Building#building.is_upgrading of
      true ->
        {error, is_upgrading};
      false ->
        {Time, _ExpAward} = lists:nth(Building#building.level, Each_level_Parm),
        timer:apply_after(Time, ?MODULE, call_upgrade_immediately, [Id]),
        io:format("~pms to complete the upgrade!~n", [Time]),
        {ok, upgrading}
    end;
    true ->
      Reply = {error, reached_maximum}
  end,
  {reply, Reply, {N, Table, Parameters}};
handle_call({upgrade_immediately, Id}, _From, {N, Table, Parameters}) ->
  [{Id, Building}] = ets:lookup(Table, Id),
  New_level = Building#building.level+1,
  UpdateBuilding = Building#building{level = New_level, is_upgrading = false},
  ets:insert(Table, {Id, UpdateBuilding}),
  io:format("upgrade complete!~p->~p~n", [Building, UpdateBuilding]),

  %%奖励经验
  {ok, Building_parm} = dict:find(building, Parameters),
  {_MaxLevel, Each_level_Parm} = lists:nth(Building#building.t_id, Building_parm),
  {_Upgrade_time,Exp_award}=lists:nth(New_level,Each_level_Parm),
  gen_server:call(role_server,{add_exp,Building#building.role_id,Exp_award}),

  Reply = {ok, UpdateBuilding},
  {reply, Reply, {N, Table, Parameters}};
handle_call({get_building_num, Role_id, T_id}, _From, {N, Table, Parameters}) ->
  Reply = {ok, building_num(Table, Role_id, T_id)},
  {reply, Reply, {N, Table, Parameters}};


handle_call(test, _From, {N, Table, Parameters}) ->
  io:format("test~n"),
  {ok, X} = dict:find(role_parm, Parameters),
  io:format("~p~n", [X]),

  {reply, ok, {N, Table, Parameters}};
handle_call({test2, Arg}, _From, {N, Table, Parameters}) ->
  io:format("test2:~p~n", [?MODULE]),
  {reply, Arg, {N, Table, Parameters}};
handle_call({test, Arg}, _From, {N, Table, Parameters}) ->
  io:format("test:~p~n", [gen_server:call(?MODULE, {test2, 2})]),
  {reply, Arg, {N, Table, Parameters}}.
handle_cast(_msg, State) ->
  {noreply, State}.

handle_info(_Info, State) ->
  {noreply, State}.

code_change(_OldVsn, N, _Extra) ->
  {ok, N}.

terminate(_Reason, _State) ->
  ok.



building_num(Table, Role_id, T_id) ->
  length(
    ets:match(Table, {'_', #building{id = '_', role_id = Role_id, t_id = T_id, level = '_', is_upgrading = '_'}})
  ).
call_upgrade_immediately(Id) ->
  gen_server:call(?MODULE, {upgrade_immediately, Id}).




delay_call(Module, Request, Time) ->
  receive
  after Time ->
    gen_server:call(Module, Request)
  end.

test() ->
  spawn(building_server, test1, [100]),
  spawn(building_server, test1, [100]).
test_loop() ->
  receive
  after 1 ->
    gen_server:call(building_server, {test, 1})
  end.

test1(0) ->
  ok;
test1(N) ->
  gen_server:call(building_server, {test, {self(), N}}),
  test1(N - 1).