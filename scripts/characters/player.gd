extends CharacterBody2D


signal interact
signal interact2

@onready var body: AnimatedSprite2D = $AnimationBody

@export var normal_speed: float = 50.0
@export var sprint_speed: float = 100.0
@export var cant_move: bool = false

var selected_crop: String = "carrot"  # Default crop
var looking_direction: String = "down"
var current_speed: float
var is_jump: bool


func _ready() -> void:
	current_speed = normal_speed
	
	SaveGame.clear_inventory()
	
	SaveGame.add_to_inventory("carrot", 50)
	SaveGame.add_to_inventory("corn", 30)
	SaveGame.add_to_inventory("eggplant", 3)
	SaveGame.add_to_inventory("potatoe", 100)


func _input(event: InputEvent) -> void:
	# Check if the interaction key is pressed
	if event.is_action_pressed("interact"):
		interact.emit()
		
	if event.is_action_pressed("interact2"):
		interact2.emit()
		
	if event.is_action_pressed("jump"):
		body.play("jump_" + looking_direction)
		

	# exit game on esc
	'''if event.is_action_pressed("ui_cancel"):
		get_tree().quit()'''


func set_selected_crop(crop_name: String) -> void:
	selected_crop = crop_name

	
func _physics_process(delta: float) -> void:
	if !cant_move:
		current_speed = sprint_speed if Input.is_action_pressed("sprint") else normal_speed
		
		var direction = Vector2.ZERO
		direction.x = Input.get_axis("move_left", "move_right")
		direction.y = Input.get_axis("move_up", "move_down")
		direction = direction.normalized()
		
		velocity = direction * current_speed

		if direction.x > 0:
			looking_direction = "right"
		elif direction.x < 0:
			looking_direction = "left"
		elif direction.y > 0:
			looking_direction = "down"
		elif direction.y < 0:
			looking_direction = "up"

		update_animation(direction)
		move_and_slide()


func update_animation(direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		if current_speed == normal_speed:
			body.play(looking_direction)
		else:
			body.play(looking_direction, 1.5)
	else:
		body.stop()
