%%%-------------------------------------------------------------------
%%% @author i008
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. 一月 2016 16:05
%%%-------------------------------------------------------------------
-module(lib_parameter).
-author("i008").

%% API
-export([load/1,is_parm/1]).

-spec load(string())->dict:dict().
load(Dir) -> %for example:load("../data/")
  {ok,Files}=file:list_dir(Dir),
  Parm_files=lists:filter(fun is_parm/1,Files),
  Parameters=dict:new(),
  load(Dir,Parameters,Parm_files).

load(_Dir,Parameters,[])->
  Parameters;
load(Dir,Parameters,[Name|T])->
  Key=list_to_atom(lists:sublist(Name,1,length(Name)-5)),
  {ok, Parm} = file:consult(Dir++Name),
  load(Dir,dict:store(Key,Parm,Parameters),T).
is_parm(Name) ->
  if
    (length(Name) > 4) ->
      Expanded_name = lists:sublist(Name, length(Name) - 4, 5),
      if
        Expanded_name =:= ".parm" ->
          true;
        true ->
          false
      end;
    true ->
      false
  end.

