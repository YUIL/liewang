-module(player_func).

-include("./player.hrl").
-compile(export_all).

level_up(Player)->
  L=Player#player.level,
  Player#player{level = L+1}.