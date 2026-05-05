# Init State

## Einleitung

Im Init State kann der Koordinator registrierung von Ggt-Prozesse entgegen nehmen.
Zudem können Starter nach den Steuer werten fragen,
um Ggt-Prozesse starten zu können.

## Detailierte Beschreibun

Der Koordinator nimmt Registrierung von Ggt-Prozesse entgegen
und speichert diese ab.
Starter Prozesse können beim Koordinator nach den Steuerwerten fragen,
die sie für die Erzeugung von den Ggt-Prozessen benötigen.
Zudem kann er in den Bereit State gebracht werden mit den step befehel
Er kann auch jeden reseten, wo er alle bisherigen Ggt-Prozesse beendet
Zudem kann er auch beednet werden mit dem kill Befehl, wobei er alle Ggt-Prozesse beendet,
sich beim Namensdienst abmeldet und sich dann selber beendet.

## Mögliche Nachfolgende States

- Bereit
- Beenden

## Mögliche Befehle

- step
- kill
- reset
