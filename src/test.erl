%%%-------------------------------------------------------------------
%%% @author i00812
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. 一月 2016 11:12
%%%-------------------------------------------------------------------
-module(test).
-author("i008").

-include("./role.hrl").
%% API
-export([]).
-compile(export_all).


test()->
  D1=dict:new(),
  D2= dict:store(1,#role{level=1},D1),
  R=dict:find(1,D2),
  io:format("1   ~p~n",[R]),
  io:format("2   ~p~n",[R#role.level]).
rpc(Pid,Function,Args)->
  Pid!{self(),{Function,Args}},
  receive
    {ok,Result}->
      Result;
    {error,Error}->
      Error
  end.

test(2)->
  file:consult("../data/building.dat").


start() ->
  Players = dict:new(),
  spawn(fun()->loop(Players) end).

loop(Players) ->
  receive
    {From, {add_player, Id}} ->
      Player = dict:find(Id,Players),
      case Player of
        error ->
          NewPlayers= dict:store(Id, #role{role_id=Id}, Players),
          From!{ok,add_success},
         loop(NewPlayers);
        _ ->
         %% io:format("player exist.~n"),
          From!{error,exist},
          loop(Players)
      end;
    {From,{add_level,Id}}->
      spawn(test,wait_and_response,[self(),{add_level1,Id},10000]),
      From!{ok,level_uping},
      loop(Players);
    {_From,{add_level1,Id}}->
      {ok,_Player} = dict:find(Id, Players),
      loop(dict:update(Id,fun(P)-> player_func:level_up(P) end, Players));

    {From, {get_level, Id}} ->
      {ok,Player} = dict:find(Id, Players),
      From ! {ok,{level,Player#role.level}},
      loop(Players);
    {From,_}->
      From!{error,no_function},
      loop(Players)
  end.

wait_and_response(Pid,Content,Time)->
  receive
  after Time->
    Pid!{self,Content}
  end.
