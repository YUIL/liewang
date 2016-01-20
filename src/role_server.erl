%%%-------------------------------------------------------------------
%%% @author i008
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. 一月 2016 16:18
%%%-------------------------------------------------------------------
-module(role_server).
-author("i008").

-include("./role.hrl").
-behavior(gen_server).
%% API
-export([]).
-compile(export_all).



start_link(Parameters) ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [Parameters], []).

init([Parameters]) ->
  State = {1, ets:new(role_table, [set, protected, named_table]), Parameters},
  {ok, State}.



handle_call(add, From, {N, Table, Parameters}) ->
  ets:insert(Table, {N, #role{role_id = N, name = "role" ++ integer_to_list(N)}}),
  Reply = {ok, N},
  {reply, Reply, {N + 1, Table, Parameters}};
handle_call({get, Id}, From, {N, Table, Parameters}) ->
  [{_, Role} | _] = ets:lookup(Table, Id),
  Reply = {ok, Role},
  {reply, Reply, {N, Table, Parameters}};
handle_call({add_exp, Id, Exp}, From, {N, Table, Parameters}) ->
  [{_, Role} | _] = ets:lookup(Table, Id),
  {ok, [{_Max_level, Each_level}]} = dict:find(role, Parameters),
  New_exp = Role#role.exp + Exp,
  ets:insert(Table, {Id, Role#role{level = level(Role#role.level, New_exp, Each_level), exp = New_exp}}),
  Reply = {ok, added},
  {reply, Reply, {N, Table, Parameters}};


handle_call({test, Arg}, From, {N, Table, Parameters}) ->
  Reply = test,
  {reply, Reply, {N, Table, Parameters}}.

handle_cast(_msg, State) ->
  {noreply, State}.

handle_info(_Info, State) ->
  {noreply, State}.

code_change(_OldVsn, N, _Extra) ->
  {ok, N}.

terminate(_Reason, _State) ->
  ok.



level(Level, Exp, Each_level) ->
  if
    Level >= length(Each_level) ->
      Level;
    true ->
      {Target_exp, _} = lists:nth(Level + 1, Each_level),
      if
        Exp < Target_exp ->
          Level;
        Exp =:= Target_exp ->
          Level + 1;
        true ->
          level(Level + 1, Exp, Each_level)
      end
  end.


