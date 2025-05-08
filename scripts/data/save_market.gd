extends Resource
class_name SavedMarket

@export var id:int
@export var item:String
@export var price:int
@export var count:int
@export var sell_time_seconds:int # Verkaufszeit in Sekunden
@export var start_time_ms:int # Startzeit des Verkaufs (Millisekunden)
@export var end_time_ms:int # Ende des Verkaufs (Millisekunden)
