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
-behavior(gen_server).
%% API
-export([]).
-compile(export_all).



start_link()->
  gen_server:start_link({local,?MODULE},?MODULE,[],[]).

init([])->
  State={1,ets:new(buiding_table,[set,protected,named_table])},
  {ok,State}.


handle_call(add,_From,{N,Table})->
  building_func:add(Table,N),
  {reply,N,{N+1,Table}};
handle_call({get,Id},_From,{N,Table})->
  [{_,Reply}|_]=ets:lookup(Table,Id),
  {reply,Reply,{N,Table}};
handle_call({upgrade,Id},_From,{N,Table})->
  Reply=1,
  {reply,Reply,{N,Table}};

handle_call({test,Arg},_From,{N,Table})->
  io:format("test:~p~n",[Arg]),
  {reply,Arg,{N,Table}}.
handle_cast(_msg,State)->
  {noreply,State}.

handle_info(_Info,State)->
  {noreply,State}.

code_change(_OldVsn,N,_Extra)->
  {ok,N}.

terminate(_Reason,_State)->
  ok.


delay_call(Module,Request,Time)->
  receive
  after Time->
    gen_server:call(Module,Request)
  end.

test()->
  spawn(building_server,test1,[100]),
  spawn(building_server,test1,[100]).
test_loop()->
  receive
  after 1->
    gen_server:call(building_server,{test,1})
  end.

test1(0)->
  ok;
test1(N)->
  gen_server:call(building_server,{test,{self(),N}}),
  test1(N-1).