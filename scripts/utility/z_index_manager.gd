extends Node

# Script that manages z-indexes for characters and objects
# This script can be attached to any node that needs automatic z-index based on y-position

# Group to add objects to for automatic z-index management
const Z_INDEX_GROUP = "z_index_managed"

# How much to divide the y position by to get z-index
const Z_INDEX_DIVISOR = 10

# Higher numbers appear in front
var z_index_offset = 0

func _ready():
	# Add this node to the z-index managed group
	if not is_in_group(Z_INDEX_GROUP):
		add_to_group(Z_INDEX_GROUP)

func _process(_delta):
	# Update z-index based on y position
	z_index = int(global_position.y / Z_INDEX_DIVISOR) + z_index_offset
	
	# Optional: print for debugging
	# print(name + " z-index: " + str(z_index) + " at position y: " + str(global_position.y))

# Static method to apply z-index management to a node
static func add_z_index_management(node):
	if not node.is_in_group(Z_INDEX_GROUP):
		node.add_to_group(Z_INDEX_GROUP)
	
	# Add a script instance if the node doesn't already have one
	if not node.has_node("ZIndexManager"):
		var script_instance = load("res://scripts/utility/z_index_manager.gd").new()
		script_instance.name = "ZIndexManager"
		node.add_child(script_instance)