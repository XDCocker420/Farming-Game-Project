extends CharacterBody2D

enum DIRECTIONS { down=1, up=2, left=3, right=4}
@export var looking_direction:DIRECTIONS = DIRECTIONS.down
@export var walk_point:Vector2 = Vector2.ZERO

func _ready() -> void:
	if walk_point == Vector2.ZERO:
		push_error("Point Not Specified")
