%%%-------------------------------------------------------------------
%%% @author i008
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. 一月 2016 16:22
%%%-------------------------------------------------------------------
-module(liewang).
-author("i008").

-define(TCP_PARMS,[{active,false},{packet,2},binary]).

%% API
-export([]).
-compile(export_all).

start()->
  Port=9091,
  case gen_tcp:listen(Port,?TCP_PARMS) of
    {ok, ListenSocket} ->
      spawn(?MODULE,start_server,[ListenSocket,1]),
      {ok, Port} = inet:port(ListenSocket),
      Port;
    {error,Reason} ->
      {error,Reason}
  end.

start_server(ListenSocket,N)->
  io:format("server accept...~n"),
  case gen_tcp:accept(ListenSocket) of
    {ok,Socket} ->
      {ok, {Address, Port}}=inet:sockname(Socket),
      io:format("accept a connection:~p ~p~n",[Address,Port]),

      spawn(?MODULE,serve,[Socket,init_gen_servers(N)]),
      start_server(ListenSocket,N+1);
    Other ->
      io:format("~w~n",[Other]),
      ok
  end.

init_gen_servers(N)->
  RoleServerName=list_to_atom("role_server"++integer_to_list(N)),
  BuildingServerName=list_to_atom("building_server"++integer_to_list(N)),
  Servers=dict:store(role_server,RoleServerName,
    dict:store(building_server,BuildingServerName,dict:new())),

  role_server:start(Servers),
  building_server:start(Servers),
  Servers.


serve(Socket,Servers)->
  case  gen_tcp:recv(Socket,0) of
    {ok,Packet}->
     %%io:format("recvvvvvvvvvvvvvv ~p~n",[binary_to_term(Packet)]),
      {Server,Request}=binary_to_term(Packet),
      {ok,ServerName}=dict:find(Server,Servers),
      Response=gen_server:call(ServerName,Request),
      gen_tcp:send(Socket,term_to_binary(Response)),
      serve(Socket,Servers);
    {error,Reason}->
      Reason
  end.





connect()->
  gen_tcp:connect("localhost",9091,?TCP_PARMS).

send(Message)->
  case gen_tcp:connect("localhost",9091,?TCP_PARMS) of
    {ok,Socket}->
      send(Socket,Message);
    {error,Reason}->
      Reason
  end.
send(Socket,Message)->
  gen_tcp:send(Socket,term_to_binary(Message)),
  Response=gen_tcp:recv(Socket,0),
  case Response of
    {ok,R}->
      binary_to_term(R);
    Other->
      Other
  end.


