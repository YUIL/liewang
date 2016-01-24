%%%-------------------------------------------------------------------
%%% @author yuil
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. 一月 2016 13:25
%%%-------------------------------------------------------------------
-module(client).
-author("yuil").
-define(TCP_PARMS, [{active, false}, {packet, 2}, binary]).


%% API
-export([]).
-compile(export_all).
%%Client
-spec connect() -> {ok, Socket} when Socket :: gen_tcp:socket().
connect() ->
  gen_tcp:connect("localhost", 9091, ?TCP_PARMS).

send(Message) ->
  case gen_tcp:connect("localhost", 9091, ?TCP_PARMS) of
    {ok, Socket} ->
      send(Socket, Message);
    {error, Reason} ->
      Reason
  end.
send(Socket, Message) ->
  gen_tcp:send(Socket, term_to_binary(Message)),
  Response = gen_tcp:recv(Socket, 0),
  case Response of
    {ok, R} ->
      binary_to_term(R);
    Other ->
      Other
  end.

%% Messge 列表
%% login                                        ->{ok,RoleId}|Other
%% {login,RoleId}                               ->ok|Other
%%  登陆成功后
%% {role_server,{get,RoleId}}                   ->{ok,#role}|{ok,Other}
%% {building_server,{add,RoleId,BuildingTypeId} ->{ok,BuildingId}|{error, reached_maximum}
%% {building_server,{get,BuildingId}            ->{ok,#building} |{ok,Other}
%% {building_server,{upgrade,BuildingId}        ->{ok,UpgradeTime}|{error, is_upgrading}|{error, reached_max_level}