extends State
class_name NPCWander

var movement_speed: float = 200.0
var movement_target_position: Vector2 = Vector2(60.0,180.0)

@onready var navigation_agent: NavigationAgent2D = $"../../NavigationAgent2D"
@onready var character:CharacterBody2D = $"../.."

func _ready() -> void:
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 4.0

	# Make sure to not await during _ready.
	actor_setup.call_deferred()
	
func physics_update(_delta:float):
	if navigation_agent.is_navigation_finished():
		return

	var current_agent_position: Vector2 = character.global_position
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()

	character.velocity = current_agent_position.direction_to(next_path_position) * movement_speed
	character.move_and_slide()
	
func process_input(_event: InputEvent):
	if _event.is_action_pressed("interact"):
		print("switch")
		transitioned.emit(self, "Talking")
	
func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(movement_target_position)

func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target


func _play_animation(anim_name: String) -> void:
	# Annahme: Der NPC besitzt als Kind einen AnimatedSprite2D mit dem Namen "AnimatedSprite2D"
	var sprite = character.get_node("AnimatedSprite2D")
	if sprite:
		sprite.play(anim_name)
