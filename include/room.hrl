%%%-------------------------------------------------------------------
%%% @author apple
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. 九月 2015 下午12:06
%%%-------------------------------------------------------------------
-author("apple").

-record(bet,{pid::pid(),userid::integer(),betinfo::list()}).

-record(user,{pid::pid(),userid::binary(),usermoney::integer(),username::binary(),usertype::boolean()}).

-record(count,{key::binary(),count::integer()}).
