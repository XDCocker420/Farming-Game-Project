extends State
class_name NPCWander

# Referenzen zu deinem NPC (CharacterBody2D) und dessen NavigationAgent2D
@export var npc: CharacterBody2D
@export var navigation_agent: NavigationAgent2D
@onready var interaction_area: Area2D = $"../../InteractArea"

@onready var player = %Player

var move_speed:float = 3.0
@onready var timer:Timer = $Timer

func _ready() -> void:
	print("budaw")
	timer.timeout.connect(make_path)
	make_path()

func physics_update(delta:float) -> void:
	var dir = npc.to_local(navigation_agent.get_next_path_position()).normalized()
	npc.velocity = dir * move_speed
	npc.move_and_slide()
	
func make_path():
	print(get_viewport().get_mouse_position())
	#navigation_agent.target_position = get_viewport().get_mouse_position()
	
func process_input(_event:InputEvent):
	if _event is InputEventMouseButton:
		navigation_agent.target_position = player.global_position
