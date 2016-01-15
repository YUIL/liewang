%%%-------------------------------------------------------------------
%%% @author i008
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. 一月 2016 17:22
%%%-------------------------------------------------------------------
-module(building_func).
-author("i008").

-include("./building.hrl").
%% API
-export([]).
-compile(export_all).

add(Table,N)->
  ets:insert(Table,{N,#building{id =N}}).

upgrade(Table,Id)->
  timer:apply_after()

