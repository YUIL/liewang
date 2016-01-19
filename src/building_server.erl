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



start_link(Parameters)->
  gen_server:start_link({local,?MODULE},?MODULE,[Parameters],[]).

init([Parameters])->
  {ok,Parameter}=dict:find(building_parm,Parameters),
  State={1,ets:new(buiding_table,[set,protected,named_table]),Parameter},
  {ok,State}.


handle_call({add,T_id},_From,{N,Table,Parameter})->
  ets:insert(Table,{N,#building{id =N,t_id = T_id}}),
  Reply={ok,N},
  {reply,Reply,{N+1,Table,Parameter}};
handle_call({get,Id},_From,{N,Table,Parameter})->
  [{_,Building}|_]=ets:lookup(Table,Id),
  Reply={ok,Building},
  {reply,Reply,{N,Table,Parameter}};
handle_call({upgrade,Id},_From,{N,Table,Parameter})->
  [{Id,Building}]=ets:lookup(Table,Id),
  case Building#building.is_upgrading of
    true->
      Reply={error,is_upgrading};
    false->
      ets:insert(Table,{Id,Building#building{is_upgrading = true}}),
      {_MaxLevel,EachLevel_Parm}=lists:nth(Building#building.t_id,Parameter),
      {Time,_ExpAward}=lists:nth(Building#building.level,EachLevel_Parm),
      timer:apply_after(Time,?MODULE,call_upgrade_immediately,[Id]),
      io:format("~pms to complete the upgrade!~n",[Time]),
      Reply={ok,upgrading}
  end,
  {reply,Reply,{N,Table,Parameter}};
handle_call({upgrade_immediately,Id},_From,{N,Table,Parameter})->
  [{Id,Building}]=ets:lookup(Table,Id),
  Level=Building#building.level,
  UpdateBuilding=Building#building{level=Level+1,is_upgrading = false},
  ets:insert(Table,{Id,UpdateBuilding}),
  io:format("~p->~p~n",[Building,UpdateBuilding]),
  Reply={ok,UpdateBuilding},
  {reply,Reply,{N,Table,Parameter}};

handle_call({test,Arg},_From,{N,Table,Parameter})->
  io:format("test:~p~n",[?MODULE]),
  {reply,Arg,{N,Table,Parameter}}.
handle_cast(_msg,State)->
  {noreply,State}.

handle_info(_Info,State)->
  {noreply,State}.

code_change(_OldVsn,N,_Extra)->
  {ok,N}.

terminate(_Reason,_State)->
  ok.


call_upgrade_immediately(Id)->
  gen_server:call(?MODULE,{upgrade_immediately,Id}).




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