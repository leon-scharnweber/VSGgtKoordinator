-module(koordinator).

-author(leon).
-compile([debug_info]).
-export([start_link/0, start/0]).

start_link() ->
    Pid = spawn_link(?MODULE, start, []),
    {ok, Pid}.

% Start State
%------------------------------------------------------------------------------
% Einstiegspunkt für den Koordinator, wo er sich beim Erlang-Node und beim Namensdienst registriert
start() ->
    Config = utils:getConfig(),
    MeinName = utils:getFromConfig(koordinatorName, Config),
    register(MeinName, self()),
    DienstNodeName = utils:getFromConfig(namensDienstNode, Config),
    registrierBeimNamensDienst(MeinName, DienstNodeName),
    init(Config, []).

% Registriert den Koordinator beim Namensdienst
registrierBeimNamensDienst(MeinName, DienstNodeName) ->
    DienstNodeName ! {self(), {bind, MeinName, node()}}.

%------------------------------------------------------------------------------

% Init State
%------------------------------------------------------------------------------
init(Config, RegProzesse) ->
    receive
        {From, getsteeringval} ->
            ArbeitsZeit = utils:getFromConfig(arbeitsZeit, Config),
            TerminierungsZeit = utils:getFromConfig(terminierungsZeit, Config),
            AnzahlGgtProzesse = utils:getFromConfig(ggtProzessAnzahl, Config),
            From ! {steeringval, ArbeitsZeit, TerminierungsZeit, AnzahlGgtProzesse},
            init(Config, RegProzesse);
        {hello, GgtProzessName} ->
            init(Config, [GgtProzessName | RegProzesse]);
        step ->
            bereit(Config, RegProzesse, infinity);
        kill ->
            kill(Config, RegProzesse)
    end.

% Wenn kill befehl gegeben wurde fährt der Koordinator das System runter,
% in dem er an alle Registrierten Ggt-Prozesse ein kill befehlt schickt
% sich beim Namensdienst abmeldet und sich beim Erland-Node abmeldet
kill(Config, RegProzesse) ->
    sendeKillAnAlleGgtProzesse(Config, RegProzesse),
    DienstNodeName = utils:getFromConfig(namensDienstNode, Config),
    MeinName = utils:getFromConfig(koordinatorName, Config),
    DienstNodeName ! {self(), {unbind, MeinName}},
    unregister(MeinName).

% versendet an alle registrierten Ggt Prozesse ein kill befehl, das sie sich beendne sollen
% Die Ggt Prozesse müssen aber auch bein Namensdienst registriert sein
sendeKillAnAlleGgtProzesse(_Config, []) ->
    ok;
sendeKillAnAlleGgtProzesse(Config, [ProzessName | Rest]) ->
    DienstNodeName = utils:getFromConfig(namensDienstNode, Config),
    PID = bekommePIDFuerName(ProzessName, DienstNodeName),
    PID ! kill,
    sendeKillAnAlleGgtProzesse(Config, Rest).

% Holt sich beim Namensdienst die PID und node für einen bestimmten Namen
bekommePIDFuerName(ProzessName, DienstNodeName) ->
    DienstNodeName ! {self(), {lookup, ProzessName}},

    receive
        {pin, {_ProzessName, Node}} ->
            Node;
        not_found ->
            error
    end.

%------------------------------------------------------------------------------

% Bereit State
%------------------------------------------------------------------------------

bereit(Config, RegProzesse, LCMi) ->
    receive
        {briefmi, {GgtProzessName, CMi, CZeit}} ->
            io:format("~p: ~p: hat einen neuer CMi berechnet: ~p~n", [CZeit, GgtProzessName, CMi]),
            case CMi < LCMi of
                true ->
                    bereit(Config, RegProzesse, CMi);
                false ->
                    bereit(Config, RegProzesse, LCMi)
            end;
        {PID, briefterm, {GgtProzessName, CMi, CZeit}} ->
            io:format("~p: ~p: hat eine Terminierung gesendet mit CMi: ~p~n", [
                CZeit, GgtProzessName, CMi
            ]),
            KorrekturFlag = utils:getFromConfig(korrekturFlag, Config),
            case KorrekturFlag andalso CMi < LCMi of
                true ->
                    PID ! {sendy, LCMi};
                false ->
                    ok
            end;
        {getinit, From} ->
            InitMi = gibRandomMi(),
            From ! {sendy, InitMi}
    end.

gibRandomMi() ->
    1.
