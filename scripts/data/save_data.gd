class_name SavedData
extends Resource

## Current level of the player
@export var player_level:int = 0
## Experience points of the player in the current level
@export var player_experience_per_level:int = 0
## Position of the player
@export var player_position:Vector2 = Vector2.ZERO
## Saved data for all dynamic parts of the level
@export var saved_data:Array[ItemSaves] = []
## Player inventory
@export var inventory:Inventory = Inventory.new()
## All contracts from the contract board
@export var contracts:Array[SavedContracts] = []
## All items that are insarated in the market
@export var market_items:Array[SavedMarket] = []
