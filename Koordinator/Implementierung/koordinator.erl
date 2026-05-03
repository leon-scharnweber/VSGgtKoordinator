-module(koordinator).
  
-author(leon).
-compile([debug_info]).
-export([start/0]).

% Start State
%------------------------------------------------------------------------------
% Einstiegspunkt für den Koordinator, wo er sich beim Erlang-Node und beim Namensdienst registriert
start() ->  Config = getConfig(),
	    MeinName = getFromConfig(koordinatorName, Config),
	    register(MeinName, self()),
	    DienstNodeName = getFromConfig(namensDienstNode, Config),
	    registrierBeimNamensDienst(MeinName, DienstNodeName),
	    init(Config, []).

% Liest aus der Koordinator Config Datei alle Konfigurationraus und gibt sie als Map zurück
getConfig() -> 
	[koordinator,
	 {namenDienst, namenDienstNode@adomayo1024},
	 false,
	 0.66,
	 10,
	 {10, 20},
	 30].

% Gibt für den Key den Value aus der Config zurück
% Es gibt:
% koordinatorName
% namensDienstNode
% korrekturFlag
% quote
% ggtProzessAnzahl
% arbeitsZeit
% terminierungsZeit
getFromConfig(What, Config) -> 
	case What of
	    koordinatorName ->
	        getByElement(0, Config);
	    namensDienstNode->
	        getByElement(1, Config);
	    korrekturFlag ->
	        getByElement(2, Config);
	    quote ->
	        getByElement(3, Config);
	    ggtProzessAnzahl ->
	        getByElement(4, Config);
	    arbeitsZeit ->
	        getByElement(5, Config);
	    terminierungsZeit ->
	        getByElement(6, Config);
	    _ ->
		error
	end


% Hilfutilfunktion um aus einer Liste ein element mit index herauszuholen
getByElement(0, [H|_T]) -> H;
getByElement(X, [_H,|T] when X > 0 -> getByElement(X-1, T);
getByElement(X, []) when X > 0 ; X < 0 -> error.

% Registriert den Koordinator beim Namensdienst
registrierBeimNamensDienst(MeinName, DienstNodeName) ->
	DienstNodeName ! {self(), {bind, MeinName, node()}}.

%------------------------------------------------------------------------------



% Init State
%------------------------------------------------------------------------------
init(Config, RegProzesse) -> 

	receive
		{From, getsteeringval} ->
			#{anzahlGgtProzesse := AnzahlGgtProzesse,
				     arbeitsZeit := ArbeitsZeit,
				     terminierungsZeit := TerminierungsZeit} = Config,
			From ! {steeringval, ArbeitsZeit, TerminierungsZeit, AnzahlGgtProzesse}, 
			init(Config, RegProzesse);
		{hello, GgtProzessName} ->
			init(Config, [GgtProzessName|RegProzesse]);
		step ->
			bereit(Config);
		kill ->
			kill(Config, RegProzesse)

	end.

% Wenn kill befehl gegeben wurde fährt der Koordinator das System runter, 
% in dem er an alle Registrierten Ggt-Prozesse ein kill befehlt schickt
% sich beim Namensdienst abmeldet und sich beim Erland-Node abmeldet
kill(Config, RegProzesse) ->
	sendeKillAnAlleGgtProzesse(Config, RegProzesse),
	#{dienstNodeName:= DienstNodeName} = Config,
	#{koordinatorName := MeinName } = Config,
	DienstNodeName ! {self(), {unbind, MeinName}},
	unregister(MeinName).





% versendet an alle registrierten Ggt Prozesse ein kill befehl, das sie sich beendne sollen
% Die Ggt Prozesse müssen aber auch bein Namensdienst registriert sein
sendeKillAnAlleGgtProzesse(_Config, []) -> ok;
sendeKillAnAlleGgtProzesse(Config, [ProzessName|Rest]) -> 
	#{dienstNodeName:= DienstNodeName} = Config,
	PID = bekommePIDFuerName(ProzessName, DienstNodeName),
	PID ! kill,
	sendeKillAnAlleGgtProzesse(Config, Rest).

% Holt sich beim Namensdienst die PID und node für einen bestimmten Namen
bekommePIDFuerName(ProzessName, DienstNodeName) ->
	DienstNodeName ! {self(), {lookup, ProzessName}},

	receive
		{pin, {Name, Node}} ->
			Node;
		not_found ->
			error
	end.
	

%------------------------------------------------------------------------------

% Bereit State
%------------------------------------------------------------------------------

bereit(Config) -> ok.
