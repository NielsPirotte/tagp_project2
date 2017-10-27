%%%-------------------------------------------------------------------
%%% @author Niels Pirotte
%%% @copyright (C) 2017, <Uhasselt>
%%% @doc
%%% car instance
%%% @end
%%% Created : 27. Oct 2017 11:47 AM
%%%-------------------------------------------------------------------
-module(car).
-author("Niels Pirotte").

%% API
-export([start/0, init/0, get/0, stop/0]).

%Type of car
-record(type, {model, passengers}).

%State of car
-record(state, {distToDrive = 0, position = 0}).

%% Deploy a new taxi
start()->
    register('car', spawn(?MODULE, init, [])),
    {ok, car}.

init() ->
  loop(#state{distToDrive = 50,position = 0}),
  {ok, []}.

% Loop function of the car
loop(State) ->
  receive
    {request, Position, Date, Dispatcher} ->
      Dispatcher ! answerRequest(Position, Date, State),
      loop(State);
    {stop, Dispatcher} ->
      Dispatcher ! 'ok - car out of service',
      ok;
    _ ->
      loop(State)
    after 1000
      -> newState(State)
  end.

% Get new state of the car after 1 second
newState(#state{distToDrive = D, position = Pos}) when D > 0 -> loop(#state{distToDrive = D-1, position = Pos});
newState(#state{distToDrive = D, position = Pos}) -> loop(#state{distToDrive = D, position = Pos});
newState(_) -> loop(#state{distToDrive = 0, position = 'home'}).

% Decide what to answer on a request
% Date moet nog worden geïmplementeerd
answerRequest(Position, _, #state{distToDrive = D, position = _}) when D > 0 -> {D, Position, 'nok'};
answerRequest(Position, _, #state{distToDrive = D, position = _})  -> {D, Position, 'ok'};
answerRequest(_,_,_) ->{'nok'}.

%% Functie die moet worden opgeroepen door andere processen
get() ->
  car ! {request, 5, 'D', self()},
  receive
    Result -> Result
  end.

%% Car out of service
stop() ->
  car ! {stop, self()},
    receive
      Result -> Result
    end.

