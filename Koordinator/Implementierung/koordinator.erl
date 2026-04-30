-module(koordinator).
-author(leon).
-compile([debug_info]).
-export([start/0]).

% Start State
%------------------------------------------------------------------------------
% Einstiegspunkt für den Koordinator, wo er sich beim Erlang-Node und beim Namensdienst registriert
start() ->  Config = getConfig(),
	    #{koordinatorName := MeinName } = Config,
	    register(MeinName, self()),
	    #{dienstNodeName:= DienstNodeName} = Config,
	    registrierBeimNamensDienst(MeinName, DienstNodeName),
	    init(Config, []).

% Liest aus der Koordinator Config Datei alle Konfigurationraus und gibt sie als Map zurück
getConfig() -> 
	#{koordinatorName => koordinator,
	 dienstNodeName => {namenDienst, namenDienstNode@adomayo1024},
	 korrekturFlag => false,
	 quote => 0.66,
	 anzahlGgtProzesse => 10,
	 arbeitsZeit => {10, 20},
	 terminierungsZeit => 30}.


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
		{step} ->
			bereit(Config)
	end.

%------------------------------------------------------------------------------

% Bereit State
%------------------------------------------------------------------------------

bereit(Config) -> ok.
