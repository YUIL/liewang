%%%-------------------------------------------------------------------
%%% @author i008
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. 一月 2016 10:23
%%%-------------------------------------------------------------------
-module(lib_misc).
-author("i008").

%% API
-export([delay_call/3]).

delay_call(Name,Request,Time)->
  receive
  after Time->
    gen_server:call(Name,Request)
  end.