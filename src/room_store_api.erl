%%%-------------------------------------------------------------------
%%% @author apple
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. 九月 2015 下午12:25
%%%-------------------------------------------------------------------
-module(room_store_api).
-author("apple").
-include_lib("eunit/include/eunit.hrl").
-include("room.hrl").



-define(BET, bet).
-define(COUNT, count).
-define(USER, user).
%% API
-export([create/0]).

create() ->
  room_store:new_ets(?COUNT, [named_table]),
  room_store:new_ets(?USER, [named_table]),
  {ok, ?BET} = room_store:new_dets(?BET, []),
  inittable(),
  ok.


inittable()->
  ets:insert(?COUNT,#count{count=0}).
%%---------------------test---------------

create_test() ->
  ok = create().
