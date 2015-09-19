%%%-------------------------------------------------------------------
%%% @author apple
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. 九月 2015 下午10:26
%%%-------------------------------------------------------------------
-module(room_server).

-author("apple").

-behaviour(gen_server).

%% API
-export([start_link/1]).

%% gen_server callbacks
-export([init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {callback :: module(), args :: any(), roomname :: any()}).

-export([start_interval/2,
  send_message_after/3]).
%%%===================================================================
%%% API
%%%===================================================================
%% -callback init(Args :: term()) ->
%%   {ok, State :: term()} | {ok, State :: term(), timeout() | hibernate} |
%%   {stop, Reason :: term()} | ignore.
%% -callback handle_call(Request :: term(), From :: {pid(), Tag :: term()},
%%     State :: term()) ->
%%   {reply, Reply :: term(), NewState :: term()} |
%%   {reply, Reply :: term(), NewState :: term(), timeout() | hibernate} |
%%   {noreply, NewState :: term()} |
%%   {noreply, NewState :: term(), timeout() | hibernate} |
%%   {stop, Reason :: term(), Reply :: term(), NewState :: term()} |
%%   {stop, Reason :: term(), NewState :: term()}.

%%%创建房间留下的消息
-callback create_room() ->
  {ok, {add, RoomName, CreateUser, RoomMaxUser}}|
  {ok, {updata, RoomName, CreateUser, RoomMaxUser}}|
  {error, Reson :: term()}.

%%%处理网关发送过来的消息
-callback handler_message(Pid :: pid(), Message :: any(), State :: any()) ->
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #state{}}.

-callback close() ->
  ok.

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @end
%%--------------------------------------------------------------------
-spec(start_link([Parms::list()]) ->
  {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link([CallBackModule, Args]) ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [CallBackModule, Args], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%%
%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------

%% -callback create_room() ->
%%   {ok, {add, RoomName, CreateUser, RoomMaxUser}}|
%%   {ok, {updata, RoomName, CreateUser, RoomMaxUser}}|
%%   {error, Reson::term()}.
-spec(init(Args :: term()) ->
  {ok, State :: #state{}} | {ok, State :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term()} | ignore).
init([CallBackModule, Args]) ->
  case CallBackModule:create_room() of
    {ok, {add, RoomName, CreateUser, RoomMaxUser}} ->
      ok = platfrom:add_room(RoomName, self(), local_time(), CreateUser, node(), RoomMaxUser),
      {ok, #state{callback = CallBackModule, roomname = RoomName, args = Args}};
    {ok, {updata, RoomName, CreateUser, RoomMaxUser}} ->
      ok = platfrom:updata_room(RoomName, self(), local_time(), CreateUser, node(), RoomMaxUser),
      {ok, #state{callback = CallBackModule, roomname = RoomName, args = Args}};
    {error, _Error} ->
      {stop, _Error}
  end.


%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_call(Request :: term(), From :: {pid(), Tag :: term()},
    State :: #state{}) ->
  {reply, Reply :: term(), NewState :: #state{}} |
  {reply, Reply :: term(), NewState :: #state{}, timeout() | hibernate} |
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), Reply :: term(), NewState :: #state{}} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_call(_Request, _From, State) ->
  {reply, ok, State, hibernate}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_cast(Request :: term(), State :: #state{}) ->
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_cast(_Request, State) ->
  {noreply, State, hibernate}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%%
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
-spec(handle_info(Info :: timeout() | term(), State :: #state{}) ->
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_info(_Info, State) ->
  {noreply, State, hibernate}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
-spec(terminate(Reason :: (normal | shutdown | {shutdown, term()} | term()),
    State :: #state{}) -> term()).
terminate(_Reason, _State = #state{callback = CallBackModule, roomname = RoomName}) ->
  ok = CallBackModule:close(),%% 房间消失之前做模块清理工作
  platfrom:delete_room(RoomName),
  ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
-spec(code_change(OldVsn :: term() | {down, term()}, State :: #state{},
    Extra :: term()) ->
  {ok, NewState :: #state{}} | {error, Reason :: term()}).
code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
%%延迟发送消息
send_message_after(Time, TargetPid, DataBin) ->
  timer:send_after(Time * 1000, {mess_to_client, TargetPid, DataBin}).

%%开始计时
start_interval(Time, Message) when Time > 0 ->
  timer:send_interval(Time, Message).

%% 本地当前时间
local_time() ->
  calendar:now_to_local_time(erlang:timestamp()).