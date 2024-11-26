# Konzept

# SaveGame
Speichert und lädt alle Art von Daten des Spieles. Außerdem kümmert es sich um das Inventarsystemes des Spieles.

##### void add_to_inventory(item:String, count:int default 1)
Wenn item, zum Beispiel carrot, vorhanden ist wird der Wert um den count erhöht und wenn es noch nicht vorhanden ist wird es angelegt.

##### void remove_from_inventory(item: String, count:int default 1, remove_completly:bool default false)
Wenn das item vorhanden ist wird die Anzahl um den count verringert. Wenn remove_completly auf true gesetzt wird wird das Item komplett gelöscht.

##### Dictionary get_inventory()
Gibt das gesammte Inventar zurück. Wenn es null ist wird ein leeres Dictionary zurück gegeben.

##### int get_item_count(item:String)
Gibt die Anzahl des Items zurück. Wenn das Item nicht existiert wird 0 zuruück gegeben.