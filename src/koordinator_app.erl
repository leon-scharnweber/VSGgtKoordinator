%%%-------------------------------------------------------------------
%% @doc koordinatorC public API
%% @end
%%%-------------------------------------------------------------------

-module(koordinator_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    koordinator_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
