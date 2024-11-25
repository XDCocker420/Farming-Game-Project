class_name SavedData
extends Resource

## Path to the level that was loaded when the game was saved
@export var player_level:int
## Position of the player
@export var player_position:Vector2
## Health of the player
@export var player_health:float
## Saved data for all dynamic parts of the level
@export var saved_data:Array[DynamicSaves] = []
## Saved data for buildings
@export var saved_buildings:Array[StaticSaves] = []
## Player inventory
@export var crops:Dictionary = {}
@export var nonCrops:Dictionary = {}