extends State
class_name  AnimalFed

var move_direction:Vector2
var wander_time:float
@export var animal:CharacterBody2D
@export var move_speed := 25.0
@onready var timer = $Timer
@onready var player:AnimatedSprite2D = $"../../AnimatedSprite2D"

var points:Array[Vector2] = [
	Vector2(-194,-136),
	Vector2(-3,-193),
	Vector2(79, -162),
	Vector2(244, -111),
	Vector2(211, -2),
	Vector2(-7, 20),
	Vector2(-226, -6)
]

var cop_points:Array[Vector2]


var looking_direction = "down"

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)
	timer.wait_time = ConfigReader.get_time(animal.name.to_lower().rstrip("1234567890"))
	

func randomize_wander():
	randomize()
	cop_points.shuffle()
	move_direction = (cop_points.front() - animal.position).normalized()
	#Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	wander_time = randf_range(1, 3)
	
func update(delta:float):
	if wander_time > 0:
		wander_time -= delta
	else:
		randomize_wander()

func enter():
	cop_points = points.duplicate()
	randomize_wander()
	timer.start()
		
func physics_update(_delta:float):
	if animal:
		animal.velocity = move_direction * move_speed
		if move_direction.x > 0:
			looking_direction = "right"
		elif move_direction.x < 0:
			looking_direction = "left"
		elif move_direction.y > 0:
			looking_direction = "down"
		elif move_direction.y < 0:
			looking_direction = "up"
		animal.move_and_slide()
		player.play(looking_direction)
		

func _on_timer_timeout():
	transitioned.emit(self, "full")
