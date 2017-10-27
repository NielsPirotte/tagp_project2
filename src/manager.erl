%%%-------------------------------------------------------------------
%%% @author Niels Pirotte
%%% @copyright (C) 2017, <Uhasselt>
%%% @doc
%%% Main file of the taxi driver application
%%% Describing the manager
%%% @end
%%% Created : 27. Oct 2017 11:35 AM
%%%-------------------------------------------------------------------
-module(manager).
-author("Niels Pirotte").

%% API
-export([]).

start()->
  register('manager', spawn(?MODULE, init, [])),
  {ok, manager}.

init() ->
  loop(0),
  {ok, []}.

loop(teller) ->
  receive
    {get, From} ->
      From ! teller,
      loop(teller);
    {stop} ->
      ok;
    _ ->
      loop(teller)
  after 1000
    -> loop(teller +1)
  end.

answ(Message) ->
  ref = make_ref(),
  manager!{ref, Message}.

%%Functie die moet worden opgeroepen door andere processen
get() ->
  manager ! {get, self()},
  receive
    Result -> Result
  end.

