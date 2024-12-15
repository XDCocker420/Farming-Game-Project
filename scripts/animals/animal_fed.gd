extends State
class_name  AnimalFed

var move_direction:Vector2
var wander_time:float
@export var animal:CharacterBody2D
@export var move_speed := 50.0
@onready var timer = $Timer
@onready var player:AnimatedSprite2D = $"../../AnimatedSprite2D"

var looking_direction = "down"

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)
	timer.wait_time = ConfigReader.get_crop_time(animal.name.to_lower())

func randomize_wander():
	move_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	wander_time = randf_range(1, 3)
	
func update(delta:float):
	if wander_time > 0:
		wander_time -= delta
	else:
		randomize_wander()

func enter():
	randomize_wander()
	timer.start()
		
func physics_update(_delta:float):
	if animal:
		animal.velocity = move_direction * move_speed
		if animal.velocity.x > 0:
			looking_direction = "right"
		elif animal.velocity.x < 0:
			looking_direction = "left"
		elif animal.velocity.y > 0:
			looking_direction = "down"
		elif animal.velocity.y < 0:
			looking_direction = "up"
		animal.move_and_slide()
		player.play(looking_direction)
		

func _on_timer_timeout():
	transitioned.emit(self, "full")
