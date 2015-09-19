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
-include_lib("erlware_commons/include/log.hrl").
-include("room.hrl").

-compile(export_all).

-define(BET, bet).
-define(COUNT, count).
-define(USER, user).
%% API
-export([create/0]).
-export([insert_user/5, get_user/1, delete_user/1]).
-export([updata_online_user_count/1, get_online_user_count/0]).
-export([insert_bet_info/3, get_bet_info/1]).

create() ->
  room_store:new_ets(?COUNT, [named_table, {keypos, #count.key}]),
  room_store:new_ets(?USER, [named_table, {keypos, #user.userid}]),
  {ok, ?BET} = room_store:new_dets(?BET, [{keypos, #bet.userid}]),
  inittable(),
  ok.


%%-record(user,{pid::pid(),userid::binary(),usermoney::integer(),username::binary()}).
insert_user(Pid, UserId, UserMoney, UserName, UserType) when is_binary(UserId) ->
  ets:insert(?USER, #user{pid = Pid, userid = UserId, usermoney = UserMoney, username = UserName, usertype = UserType});
insert_user(Pid, UserId, UserMoney, UserName, UserType) ->
  ?TRACE("insert parms error", [Pid, UserId, UserMoney, UserName, UserType]).

get_user(UserId) ->
  ets:lookup(?USER, UserId).
delete_user(UserId) ->
  ets:delete(?USER, UserId).

updata_online_user_count(Parms) when is_integer(Parms) ->
  case updata_online_user_parms_check(Parms) of
    true ->
      [Count | _Any] = ets:lookup(?COUNT, <<"count">>),
      Total = Count#count.count + Parms,
      case Total > 0 of
        true ->
          ets:insert(?COUNT, Count#count{count = Total}),
          Total;
        false ->
          ets:insert(?COUNT, Count#count{count = 0}),
          0
      end;
    false ->
      ?TRACE("Parms error")
  end.

get_online_user_count() ->
  case ets:lookup(?COUNT, <<"count">>) of
    [Count | _Any] ->
      Count#count.count;
    [] -> 0
  end.

%%押注的数据格式 pid,[{0,1000},{1,10000}....{n,100000}].
insert_bet_info(Pid, UserId, {Index, Money}) ->
  case dets:lookup(?BET, UserId) of
    [BetRecord | _] ->
      NewList = deal_bet_info(BetRecord#bet.betinfo, {Index, Money}),
      %%io:format("NewList~p~n", [NewList]),
      dets:insert(?BET, BetRecord#bet{betinfo = NewList});
    [] ->
      %%io:format("NewList NULL"),
      dets:insert(?BET, #bet{pid = Pid, userid = UserId, betinfo = [{Index, Money}]})
  end.
get_bet_info(UserId) ->
  dets:lookup(?BET, UserId).
%%匹配出所有的押注数据
get_all_bet_info() ->
  dets:match(?BET, '$1').


%%--------------------private--------------------
inittable() ->
  ets:insert(?COUNT, #count{key = <<"count">>, count = 0}).
%%押注数据处理
deal_bet_info(BetList, {Index, Money}) ->
  deal_bet_info(BetList, {Index, Money}, []).

deal_bet_info([{SIndex, SMoney} | BetTail], {Index, Money}, NewList) ->
  case SIndex =:= Index of
    true -> Nlist = [{SIndex, SMoney + Money} | NewList],
      lists:merge(Nlist, BetTail);
    false ->
      deal_bet_info(BetTail, {Index, Money}, [{SIndex, SMoney} | NewList])
  end;

deal_bet_info([], {Index, Money}, NewList) ->
  [{Index, Money} | NewList].

%%在线人数更新参数检测
updata_online_user_parms_check(1) ->
  true;
updata_online_user_parms_check(-1) ->
  true;
updata_online_user_parms_check(_Any) ->
  false.

%%---------------------test---------------

create_test() ->
  ok = create().
bet_info_test(Count) ->
  %%create(),
  {_Total, Time} = platfrom_util:run_time_diff(fun() ->
    [insert_bet_info(self(), (900+Index rem 12), {Index rem 12, 1000 * Index}) || Index <- lists:seq(1, Count)]
  end),
  io:format("time~p~n", [Time]).

%%io:format("bet ~p~n",[self()]),
%%io:format("bet ~p~n",[get_bet_info(self())]).




