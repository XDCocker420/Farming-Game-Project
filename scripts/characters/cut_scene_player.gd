extends CharacterBody2D

@onready var body: AnimatedSprite2D = $AnimationBody

var looking_direction: String = "down"
var current_speed: float
var follow:bool = false
var follow_mouse:bool = false

var walk_pos:Vector2
var follow_pos:bool = false

@onready var camera:Camera2D = $Camera2D

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

@export var martha:CharacterBody2D

func _ready() -> void:
	direction_changed.connect(_on_direction_changed)
	cant_move_changed.connect(_on_cant_move_changed)
	body.animation_finished.connect(_on_anim_end)

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
	if !cant_move && body.animation in ["right", "left", "up", "down"]:
		current_speed = sprint_speed if Input.is_action_pressed("sprint") else normal_speed
		
		var direction = Vector2.ZERO
		if !follow and !follow_mouse and !follow_pos:
			direction.x = Input.get_axis("move_left", "move_right")
			direction.y = Input.get_axis("move_up", "move_down")
		elif follow:
			direction = (martha.global_position + Vector2(-30, 30)) - global_position
			if direction.length() < 1.0:
				direction = Vector2.ZERO
		elif follow_pos:
			direction = walk_pos - global_position
			if direction.length() <= 1.0:
				follow_pos = false
				direction = Vector2.ZERO
		elif follow_mouse:
			direction = get_global_mouse_position() - global_position
			if direction.length() <= 1.0:
				direction = Vector2.ZERO
		
			
		direction = direction.normalized()
		
		velocity = direction * current_speed

		# Update looking direction based on movement
		# Prioritize horizontal movement when moving diagonally
		if abs(direction.x) > abs(direction.y):
			# Horizontal movement has priority
			if direction.x > 0:
				looking_direction = "right"
			elif direction.x < 0:
				looking_direction = "left"
		else:
			# Vertical movement has priority or equal priority
			if direction.y > 0:
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
		
func follow_martha(val:bool):
	cant_move = false
	follow = val
	
func _follow_mouse(val:bool):
	get_viewport().warp_mouse(get_viewport_rect().size / 2.0)
	follow_mouse = val
	
func walk_to(pos:Vector2):
	walk_pos = pos
	follow_pos = true
	
func do_harvest():
	#cant_move = true
	body.play("hoe_"+looking_direction)
	
func do_water():
	body.play("water_"+looking_direction)

func _on_anim_end():
	body.animation = looking_direction
