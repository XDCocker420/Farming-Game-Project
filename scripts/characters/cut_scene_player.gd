extends CharacterBody2D

@onready var body: AnimatedSprite2D = $AnimationBody

var looking_direction: String = "down"
var current_speed: float

signal direction_changed(new_direction)
signal cant_move_changed(new_value)

enum ANIMATION {DOWN, UP, LEFT, RIGHT, JUMP}
@export var animation_direction:ANIMATION = ANIMATION.DOWN:
	set(value):
		direction_changed.emit(value)
		animation_direction = value

@export var cant_move:bool = false:
	set(value):
		cant_move_changed.emit(value)
		cant_move = value
		
@export var normal_speed: float = 50.0
@export var sprint_speed: float = 100.0

func _ready() -> void:
	direction_changed.connect(_on_direction_changed)
	cant_move_changed.connect(_on_cant_move_changed)

func _on_cant_move_changed(new_val):
	if new_val:
		body.stop()

func _on_direction_changed(new_val):
	match new_val:
		ANIMATION.DOWN:
			looking_direction = "down"
		ANIMATION.UP:
			looking_direction = "up"
		ANIMATION.LEFT:
			looking_direction = "left"
		ANIMATION.RIGHT:
			looking_direction = "right"
	
	body.play(looking_direction)
	body.stop()
	
			

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
