# Spielkonzept
- [Spielkonzept](#spielkonzept)
- [Spielkreislauf](#spielkreislauf)
    - [Pflanzen](#pflanzen)
    - [Tiere](#tiere)
        - [Arten von Tieren:](#arten-von-tieren)
    - [Lagern](#lagern)
    - [Verkaufen](#verkaufen)
        - [Marktplatz](#marktplatz)
        - [Auftragsbrett](#auftragsbrett)
        - [Beispiel Auftrag:](#beispiel-auftrag)
    - [Möglichkeiten mit dem Geld](#möglichkeiten-mit-dem-geld)
        - [Erweiterungen](#erweiterungen)
        - [Spielehalle](#spielehalle)
    - [Produktionsgebäude](#produktionsgebäude)
        - [!! Tierfuttermühle !!](#-tierfuttermühle-)
        - [Molkerei](#molkerei)
        - [Honigschleuder](#honigschleuder)
        - [Bäckerei](#bäckerei)
        - [Schlachthof](#schlachthof)
        - [Grillhaus](#grillhaus)
        - [Konditorei](#konditorei)
        - [Schneiderei und Weberei](#schneiderei-und-weberei)
- [Systeme](#systeme)
    - [Levelsystem](#levelsystem)
    - [NPCs](#npcs)
    - [Das Dorf](#das-dorf)
- [Story](#story)
    - [Charaktere](#charaktere)
        - [Großeltern](#großeltern)
        - [Martha](#martha)
        - [Adrian](#adrian)
- [Erweiterungsmöglichkeiten](#erweiterungsmöglichkeiten)
    - [Editor für die Farm](#editor-für-die-farm)
    - [Hauskauf und personalisierungs System](#hauskauf-und-personalisierungs-system)
    - [Weiterentwicklung der Story](#weiterentwicklung-der-story)
    - [Beziehungssystem mit NPCs](#beziehungssystem-mit-npcs)
- [Keymap](#keymap)
        - [W](#w)
        - [A](#a)
        - [S](#s)
        - [D](#d)
        - [Left-Shift](#left-shift)
        - [E](#e)
        - [F](#f)
- [Spielversionen](#spielversionen)
    - [Testing](#testing)
    - [Production](#production)
    - [Tag der offenen Tür 2025](#tag-der-offenen-tür-2025)


# Spielkreislauf

### Pflanzen
Pflanzen werden mit 1ner Pflanze der selben Art angebaut. Beim abbauen bekommt man entweder 1, 2 oder 3 Karotten. Wahrscheinlichkeiten: 5% 1 Stück 85% 2 Stück, 10% 3 Stück. Wenn man die Pflanzen gießt steigt die Wahrscheinlich auf 2 oder 3 Stück.

### Tiere
Damit Tiere ihre Produkte, wie z.B. bei der Kuh die Milch, produzieren können, benötigen sie Tierfutter. Tierfutter wird in einer Tierfuttermühle produziert. Es besteht aus verschiedenen Pflanzen. Tiere können für Fleisch geschlachtet werden.

##### Arten von Tieren:
- Schafe (auch in schwarz vorhanden)
- Kühe (auch in schwarz vorhanden)
- Hühner (auch in schwarz vorhanden)
- Bienen

### Lagern
Die Ernte wird automatisch in die Scheune übertragen. Es gibt kein eigenes Spielerinventar. Die Scheune wir absteigend sortiert. Wenn es von einem Item 0 gibt wird es nicht angezeigt.

### Verkaufen
Es gibt einen Marktplatz und ein Auftragsbrett.
##### Marktplatz
Auf dem Marktplatz können Items zu frei wählbaren Preisen verkauft werden. Der minimal Preis beträgt 1 und der maximal Preis beträgt der im ConfigFile angegebene maxPrice z.B. 72. Am Anfang gibt es vier Slots. Die weiteren Slots können mit Gold erkauft werden. Pro Slot kann maximal ein Item-Typ mit einer Anzahl von 1 bis 10 verkauft werden. Der Marktplatz gibt keine Erfahrungspunkte.

##### Auftragsbrett
Auf diesem werden Aufträge von Personen aus dem Dorf ausgeschrieben. Sie werden zufällig erstellt. Diese geben Geld und Erfahrungspunkte. Die Erfahrungspunkte werden zufällig zwischen bestimmten Werten gebildet aus der Summe der Items aus den ConfigFiles. Diese varieren zufällig. Das Geld verhält sich wie die Erfahungspunkte aber die Waren sind weniger Wert als wenn sie auf dem Marktplatz verkauft wird.

##### Beispiel Auftrag:

| Auftrag von Bertha               |
|----------------------------------|
| 12x Weizen                       |
| 4x Wolle                         |
| 214 Gold<br>187 Erfahrungspunkte |

### Möglichkeiten mit dem Geld
##### Erweiterungen
Mit voranschreitendem Level schaltet der Spieler neue Elemente des Spieles frei. Diese Elemente z.B. neue Tiere oder Produktionsgebäude kosten einen bestimmten, momentan noch nicht festgelegten, Geldbetrag.

##### Spielehalle
In einer Spielehalle, welche sich an der aus Pokémon Diamant orientiert,kann über verschiedene Maschinen seltene Items oder Gold erspielt werden. Es ist nicht möglich mit Echtgeld zu spielen oder dieses zu gewinnen also qualifiziert es sich nicht als Casino.

### Produktionsgebäude
##### !! Tierfuttermühle !!
In diesem Gebäude wird Tierfutter für verschiedene Tiere hergestellt. Jedes Tierart hat ihr eigenes Futter. Tierfutter wird aus verschiedenen Arten von Pflanzen zusammengesetzt.

| Tierfutter    | Pflanzen             |
|---------------|----------------------|
| Hühnerfuttter | 2x Weizen<br>1x Mais |
| Kuhfutter     | 2x Mais<br>1x Kürbis |
| Schafsfutter  | 2x Salat<br>1x Mais  |

##### Molkerei
In der Molkerei kann Milch verarbeitet werden. Milch wird zu Käse, Butter und Schlagobers verarbeitet.

##### Honigschleuder
Aus Honigwaben kann mit dieser Maschine Honig gewonnen werden.

##### Bäckerei
In der Bäckerei können verschiedene Arten von Backwaren, wie zum Beispiel Brot, Muffins oder Pizaa, hergestellt werden

##### Schlachthof
Tiere werden zum Schlachthof gebracht und nach einer Zeit kann man das Fleisch der Tiere abholen. Es wird auf bildliche Darstellung des Schlachtprozesses und Blut verzichtet.

##### Grillhaus
Hier wird Fleisch weiter verarbeitet. Es ist möglich Spiegelei mit Speck, Burger und gebratener Kürbis herzustellen.

##### Konditorei
In der Konditorei werden verschiedene Kuchenarten hergesellt. Die genauen Arten von Kuchen muss noch festgelegt werden.

##### Schneiderei und Weberei
Hier wird die Wolle der Schafe weiter verarbeitet. Es können verschiedene Artikel aus wolle hergesllt werden wie zum Beispiel Pullover in verschiedenen Farben und Hauben.


# Systeme
### Levelsystem
Erfahrungspunkte können über Auftrage vom Auftragsbrett oder über das ernten von Pflanzen und Tieren erhalten werden. In level.cfg wird festgehalten ab welcher Anzahl von Erfahrungspunkten welches Level erreicht wird. Mit den erhaltenen Erfahrungspunkten werden verschiedene Aspekte des Spieles freigeschalten. Dazu zählen zum Beispiel neue Tiere oder neue Pflanzen.

### NPCs
NPCs sind nicht spielbare Charaktere welche im Dorf leben. Mit ihnen kann man reden und handeln. Mit ihnen kann man Waren in niedriger Anzahl gegen Geld tauschen. Sie können nicht zum Bauernhof gehen da sie nicht wollen.

### Das Dorf
Das Dorf besteht aus vielen kleinen Häusern. Man kann jedes Haus betreten und sich mit allen NPCs unterhalten. In der Stadt gibt es auch verschiedene Geschäfte. In diesen kann man zum Beispiel neue Pflanzen oder Tiere kaufen. Das Dorf ist dafür da, damit der Spieler einen Anreiz hat Geld zu verdienen. 

# Story
Du erhältst einen Brief. Deine verloren gegelaubten Großeltern haben dir ihren alten Bauernhof in St. Catchpole vererbt. Da du gerade arbeitslos bist und dich auf ein neues Arbenteuer freust, beschließt du auf den Bauernhof zu ziehen. Dort erwartet dich Martha. Sie erklärt dir, dass sie eine gute Freundin deiner Oma war. Sie erklärt dir wo deine Scheune liegt, wie du Pflanzen anbaust und wie du deine Bestellungen abschließt. Danach lädt sie dich auf einen Kaffee im Dorf ein. Sie zeigt dir zuerst das Dorf. Dort zeigt sie die Spielehalle, den Marktplatz und zuletzt das Kaffee. Nach einem Kaffee geht sie nach Hause und du beginnst deine Arbeit als frisch geborener Farmer.

### Charaktere
##### Großeltern
Status: Tot <br>

##### Martha
Status: lebendig & verheiratet <br>

##### Adrian
Status: lebendig & verheiratet <br>

# Erweiterungsmöglichkeiten
Dies sind weitere Ideen zur Erweiterung des Spieles falls das Spiel früher fertig ist als gedacht.

### Editor für die Farm
Über einen sozusagen Editor kann der Spieler seine Farm so personalisieren wie er möchte. Er kann zum Beispiel die Anordnung der Felder verändern oder auf der Farm irgendwo frei platzieren. Dadurch kann sich der Spieler kreativ frei ausleben.

### Hauskauf und personalisierungs System
Mit dem erspielten Geld kann der Spieler sein eigenes Haus in der Stadt kaufen. Dieses Haus kann er so anpassen wie er will von innen und außen. Damit kann der Spieler dem Spiel seinen individuellen Touch geben.

### Weiterentwicklung der Story
Die Geschichte des Spiels könnte weiter ausgebaut werden und die NPCs würden somit mehr Relevanz im Spiel erhalten. 

### Beziehungssystem mit NPCs
Der Spieler kann seine Beziehung mit verschiedenen NPCs verstärken zum Beispiel in dem sie gemeinsam einen Kaffee trinken gehen. Dadurch könnte der Spieler emotionaler mit dem Spiel verbunden sein.

# Keymap

##### W
Name: move_up <br>| Benutzt von:
- Player Movement

##### A
Name: move_left <br>| Benutzt von:
- Player Movement

##### S
Name: move_down <br>| Benutzt von:
- Player Movement

##### D
Name: move_right <br>| Benutzt von:
- Player Movement

##### Left-Shift
Name: sprint <br>| Benutzt von:
- Player Sprinting

##### E
Name: interact
Abbauen, Anbauen, Öffnen von Türen <br>| Benutzt von:
- BasicHaus
- Scheune
- Anbau Feldern

##### F
Name: interact2
Momentan mit interact2 belegt <br>| Benutzt von:
- unbenutzt

# Spielversionen

### Testing
In dieser Version wird die Zeit um 30% reduziert.

### Production
Diese Version beinhaltet keine sonder Regelungen.

### Tag der offenen Tür 2025
In dieser Version des Spieles wird die Zeit für das wachsen jeglicher Pflanzen und die Zeit für die Produktion aller Materialen sehr stark reduziert.
