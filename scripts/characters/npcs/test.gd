extends CharacterBody2D

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

@export var player:CharacterBody2D

var move_speed:float = 20.0
@onready var timer:Timer = $Timer

func _ready() -> void:
	timer.timeout.connect(make_path)
	make_path()

func _physics_process(delta: float) -> void:
	var dir = to_local(navigation_agent.get_next_path_position()).normalized()
	velocity = dir * move_speed
	move_and_slide()
	
func make_path():
	navigation_agent.target_position = player.global_position

#func _input(_event:InputEvent):
#	if _event is InputEventMouseButton:
#		navigation_agent.target_position = player.global_position
