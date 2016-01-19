%%%-------------------------------------------------------------------
%%% @author i008
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. 一月 2016 16:18
%%%-------------------------------------------------------------------
-module(player_server).
-author("i008").

-include("./player.hrl").
-behavior(gen_server).
%% API
-export([]).
-compile(export_all).



start_link(Parameters) ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [Parameters], []).

init([Parameters]) ->
  {ok, Parameter} = dict:find(player_parm, Parameters),
  State = {1, ets:new(player_table, [set, protected, named_table]), Parameters},
  {ok, State}.



handle_call(add, From, {N, Table, Parameter}) ->
  ets:insert(Table, {N, #player{id = N, name = "player" ++ integer_to_list(N)}}),
  Reply = {ok, N},
  {reply, Reply, {N + 1, Table, Parameter}};
handle_call({get, Id}, From, {N, Table, Parameter}) ->
  [{_, Player} | _] = ets:lookup(Table, Id),
  Reply = {ok, Player},
  {reply, Reply, {N, Table, Parameter}};
handle_call({get_building_num, PlayerId, BuildingId}, From, {N, Table, Parameter}) ->
  [{_, Player} | _] = ets:lookup(Table, PlayerId),
  Reply = {ok, player_func:building_num(Player, BuildingId)},
  {reply, Reply, {N, Table, Parameter}};


handle_call({test, Arg}, From, {N, Table, Parameter}) ->
  Reply = test,
  {reply, Reply, {N, Table, Parameter}}.

handle_cast(_msg, State) ->
  {noreply, State}.

handle_info(_Info, State) ->
  {noreply, State}.

code_change(_OldVsn, N, _Extra) ->
  {ok, N}.

terminate(_Reason, _State) ->
  ok.




building_num(Player, BuildingId) ->
  Buildings = Player#player.buildings,
  Num = dict:find(BuildingId, Buildings),
  if
    Num =:= error ->
      0;
    true ->
      {ok, Num1} = Num,
      Num1
  end.