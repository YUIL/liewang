%%%-------------------------------------------------------------------
%%% @author yuil
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. 一月 2016 11:37
%%%-------------------------------------------------------------------
-module(server_socket).
-author("yuil").

-define(TCP_PARMS, [{active, false}, {packet, 2}, binary]).
-define(LOGIN_SERVER,main_server).

%% API
-export([]).
-compile(export_all).

%%创建一个进程监听端口9091
start() ->
  Port = 9091,
  case gen_tcp:listen(Port, ?TCP_PARMS) of
    {ok, ListenSocket} ->
      spawn(?MODULE, start_server, [ListenSocket]),
      {ok, Port} = inet:port(ListenSocket),
      Port;
    {error, Reason} ->
      {error, Reason}
  end.

%%监听端口，每接收一个连接就创建一个进程和对应的gen_server
%%然后登陆
start_server(ListenSocket) ->
  io:format("server accept...~n"),
  case gen_tcp:accept(ListenSocket) of
    {ok, Socket} ->
      {ok, {Address, Port}} = inet:sockname(Socket),
      io:format("accept a connection:~p ~p~n", [Address, Port]),
      %%登陆
      spawn(?MODULE,login,[Socket]),
      start_server(ListenSocket);
    Other ->
      io:format("~w~n", [Other]),
      ok
  end.

login(Socket) ->
  Response =
    case gen_tcp:recv(Socket, 0) of
      {ok, Packet} ->
        io:format("login recvvvv~p~n", [binary_to_term(Packet)]),
        Message = binary_to_term(Packet),
        case Message of
          {login, RoleId} ->
            case gen_server:call(?LOGIN_SERVER, {login, RoleId}) of
              ok ->
                spawn(?MODULE, serve, [Socket, RoleId]),
                ok;
              Other ->
                Other
            end;
          login ->
            case gen_server:call(?LOGIN_SERVER, login) of
              {ok, RoleId} ->
                spawn(?MODULE, serve, [Socket, RoleId]),
                {ok,RoleId};
              Other ->
                Other
            end;
          Other ->
            io:format("Other:~p~n",[Other]),
            login(Socket)
        end
    end,
  gen_tcp:send(Socket, term_to_binary(Response)).



serve(Socket, RoleId) ->
  case gen_tcp:recv(Socket, 0) of
    {ok, Packet} ->
      io:format("serve recvvvv~p~n", [binary_to_term(Packet)]),
      {ServerName, Request} = binary_to_term(Packet),
      io:format("1111111111~n"),

      ServerName1 = list_to_atom(atom_to_list(ServerName) ++ integer_to_list(RoleId)),
      io:format(" whereis ~p:~p~n",[ServerName1,whereis(ServerName1)]),
      Response = gen_server:call(ServerName1, Request),
      io:format("serve recvvvv~p~n", [binary_to_term(Packet)]),

      gen_tcp:send(Socket, term_to_binary(Response)),
      serve(Socket, RoleId);
    {error, Reason} ->
      Reason
  end.
