1. {PID, getsteeringval}
2. {hello, GgtProzessName}
3. {briefmi, {GgtProzessName, CMi, CZeit}}
4. {PID, briefterm, {GgtProzessName, CMi, CZeit}}
5. {getinit, From}

## Steuer Werter für die Ggt-Prozesse

### Aufruf

{PID, getsteeringval}

### Return

{steeringval, {ATMin, AZMax}, TermZeit, GgtProzessAnzahl}

## Registrierung der Ggt-Prozesse

### Aufruf

{hello, GgtProzessName}

## Benachrichtigen über neuen Mi

### Aufruf

{briefmi, {GgtProzessName, CMi, CZeit}}

## Benachrichtigung über Terminierung

### Aufruf

{PID, briefterm, {GgtProzessName, CMi, CZeit}}

### Return

{sendy, LCMi} (wenn Korrektur Flag gesetzt)

## Init Wert für Starter Ggt-Prozesse

### Aufruf

{getinit, From}

### Return

{sendy, InitMi}
