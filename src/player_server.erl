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


-behavior(gen_server).
%% API
-export([]).
-compile(export_all).



start_link()->
  gen_server:start_link({local,?MODULE},?MODULE,[],[]).

init([])->
  State=ets:new(player_table,[set,protected,named_table]),
  {ok,State}.

handle_call({add,Id},From,State)->
  Reply=1,
  {reply,Reply,State}.

handle_cast(_msg,State)->
  {noreply,State}.

handle_info(_Info,State)->
  {noreply,State}.

code_change(_OldVsn,N,_Extra)->
  {ok,N}.

terminate(_Reason,_State)->
  ok.

