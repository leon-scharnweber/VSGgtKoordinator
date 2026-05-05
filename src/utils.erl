-module(utils).
-author(leon).
-export([getConfig/0, getFromConfig/2]).

-define(KOORDINATOR_NAME, 0).
-define(NAMENSDIENST, 1).
-define(KOOREKTUR_FLAG, 2).
-define(QUOTE, 3).
-define(ANZAHL_GGT, 4).
-define(ARBEITSZEIT, 5).
-define(TERMINIERUNGSZEIT, 6).

% Liest aus der Koordinator Config Datei alle Konfigurationraus und gibt sie als Map zurück
getConfig() ->
    [
        koordinator,
        {namenDienst, namenDienstNode@adomayo1024},
        false,
        0.66,
        10,
        {10, 20},
        30
    ].

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
            getByElement(?KOORDINATOR_NAME, Config);
        namensDienstNode ->
            getByElement(?NAMENSDIENST, Config);
        korrekturFlag ->
            getByElement(?KOOREKTUR_FLAG, Config);
        quote ->
            getByElement(?QUOTE, Config);
        ggtProzessAnzahl ->
            getByElement(?ANZAHL_GGT, Config);
        arbeitsZeit ->
            getByElement(?ARBEITSZEIT, Config);
        terminierungsZeit ->
            getByElement(?TERMINIERUNGSZEIT, Config);
        _ ->
            error
    end.

% Hilfutilfunktion um aus einer Liste ein element mit index herauszuholen
getByElement(0, [H | _T]) -> H;
getByElement(X, [_H | T]) when X > 0 -> getByElement(X - 1, T);
getByElement(X, []) when X > 0; X < 0 -> error.
