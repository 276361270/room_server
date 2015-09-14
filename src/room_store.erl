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

%% API
-export([]).

-compile(export_all).


new_ets(Name, Opts) ->
  ets:new(Name, Opts).


new_dets(Name, Opts) ->
  dets:open_file(Name, [{type, bag}, {file, "./table/" ++ ec_cnv:to_list(Name) ++ ".table"}, {ram_file, true} | Opts]).
