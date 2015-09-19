%%%-------------------------------------------------------------------
%%% @author apple
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. 九月 2015 下午9:19
%%%-------------------------------------------------------------------
-module(room_store).
-author("apple").
-include_lib("erlware_commons/include/log.hrl").

%% API
-export([new_ets/2, new_dets/2,new_dets/3]).

-compile(export_all).


new_ets(Name, Opts) ->
  ets:new(Name, Opts).

new_dets(Name, Opts) ->
  new_dets(Name, "data", Opts).

new_dets(Name, Path, Opts) ->
  ok = ensure_data_path(Path),
  dets:open_file(Name, [{file, ec_cnv:to_list(Path) ++ "/" ++ ec_cnv:to_list(Name) ++ ".dat"} | Opts]).

ensure_data_path(Path) ->
  ec_file:mkdir_p(ec_cnv:to_list(Path)).


%%%----------------------test--------------------------
dets_test() ->
  new_dets(demo, []),
  dets:insert(demo, {1, 2, 3}),
  dets:insert(demo, {2, 3, 4}),
  new_dets(game, []),
  dets:insert(game, {1, 2, 3}),
  dets:insert(game, {2, 3, 4}).

reload_test() ->
  A1 = dets:lookup(demo, 1),
  A2 = dets:lookup(demo, 2),
  A3 = dets:lookup(demo, 1),
  A4 = dets:lookup(demo, 2),
  ?TRACE([A1, A2, A3, A4]).

