class_name SavedData
extends Resource

## Path to the level that was loaded when the game was saved
@export var player_level:int
## Position of the player
@export var player_position:Vector2
## Saved data for all dynamic parts of the level
@export var saved_data:Array[ItemSaves] = []
## Player inventory
@export var inventory:Inventory