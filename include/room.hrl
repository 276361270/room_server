%%%-------------------------------------------------------------------
%%% @author apple
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. 九月 2015 下午12:06
%%%-------------------------------------------------------------------
-author("apple").

-record(bet,{pid::pid(),betinfo::any()}).

-record(user,{pid::pid(),userid::any(),usermoney::integer(),username::binary()}).

-record(count,{count::integer()}).
